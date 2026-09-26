(function installWristScroll(global) {
  'use strict';

  var rememberedTarget = null;

  function asElement(node) {
    if (!node) return null;
    if (node.nodeType === 1) return node;
    return node.parentElement || null;
  }

  function isConnectedElement(element) {
    return !!(element && element.nodeType === 1 && element.isConnected);
  }

  function isScrollable(element) {
    if (!element || element === document.body || element === document.documentElement) {
      return false;
    }
    var style = global.getComputedStyle(element);
    var overflow = style && style.overflowY;
    var acceptsScroll = overflow === 'auto' || overflow === 'scroll' || overflow === 'overlay';
    return acceptsScroll && element.scrollHeight > element.clientHeight;
  }

  function nearestScrollableAncestor(node) {
    var element = asElement(node);
    while (isConnectedElement(element) && element !== document.body && element !== document.documentElement) {
      if (isScrollable(element)) return element;
      element = element.parentElement;
    }
    return null;
  }

  function documentScroller() {
    return document.scrollingElement || document.documentElement || document.body;
  }

  function targetForCommand() {
    var focused = document.activeElement;
    var focusedScroller = nearestScrollableAncestor(focused);
    if (focusedScroller) return focusedScroller;

    var rememberedScroller = nearestScrollableAncestor(rememberedTarget);
    if (rememberedScroller) return rememberedScroller;

    return documentScroller();
  }

  function positionOf(target) {
    var maximum = Math.max(0, target.scrollHeight - target.clientHeight);
    if (!maximum) return 0;
    return Math.max(0, Math.min(1, target.scrollTop / maximum));
  }

  function result(ok, moved, target, reason) {
    return {
      ok: ok,
      moved: moved,
      position: positionOf(target),
      reason: reason
    };
  }

  function wristScroll(command) {
    var target = targetForCommand();
    if (!command || typeof command !== 'object' || Array.isArray(command)) {
      return result(false, false, target, 'invalid-command');
    }

    var amount = command.amount;
    var delta;
    if (command.kind === 'scroll') {
      if (typeof amount !== 'number' || !Number.isFinite(amount) || amount < -1 || amount > 1) {
        return result(false, false, target, 'invalid-amount');
      }
      delta = amount * target.clientHeight;
    } else if (command.kind === 'page') {
      if (amount !== -1 && amount !== 1) {
        return result(false, false, target, 'invalid-amount');
      }
      delta = amount * target.clientHeight * 0.85;
    } else {
      return result(false, false, target, 'invalid-command');
    }

    var maximum = Math.max(0, target.scrollHeight - target.clientHeight);
    if (!maximum) return result(true, false, target, 'not-scrollable');

    var before = target.scrollTop;
    var next = Math.max(0, Math.min(maximum, before + delta));
    // A page's CSS scroll-behavior must not create delayed movement after our reply.
    target.scrollTo({ top: next, behavior: 'instant' });
    var moved = target.scrollTop !== before;
    return result(true, moved, target, moved ? 'scrolled' : 'at-boundary');
  }

  document.addEventListener('pointerdown', function rememberPointerTarget(event) {
    rememberedTarget = asElement(event.target);
  }, true);

  global.wristScroll = wristScroll;
})(globalThis);
