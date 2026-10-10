(function () {
  if (window.VeruTheme) return;

  var LOGO = 'https://cdn.veru.qzz.io/uDgbtf.png';
  var RING_C = 2 * Math.PI * 54;

  function easeOutCubic(t) {
    return 1 - Math.pow(1 - t, 3);
  }

  function runLoader(fast) {
    var loader = document.querySelector('.vq-loader');
    if (!loader) return;

    var pctEl = loader.querySelector('.vq-loader__pct');
    var ring = loader.querySelector('.vq-loader__bar');
    var img = loader.querySelector('.vq-loader__logo');

    if (img && !img.src) img.src = LOGO;
    if (!ring) return;

    ring.style.strokeDasharray = RING_C;
    ring.style.strokeDashoffset = RING_C;

    // shortcut: percent is a timed animation, not real page-load progress; upgrade = server-side progress endpoint.
    var duration = fast ? 400 : 1200;
    var start = null;

    var id = document.getElementById('vq-ring-track');
    if (id) id.style.strokeDasharray = RING_C;

    function frame(ts) {
      if (start === null) start = ts;
      var p = Math.min((ts - start) / duration, 1);
      var eased = easeOutCubic(p);
      var pct = Math.round(eased * 100);
      if (pctEl) pctEl.textContent = pct;
      ring.style.strokeDashoffset = RING_C * (1 - eased);
      if (p < 1) {
        requestAnimationFrame(frame);
      } else {
        loader.classList.add('vq-loader--done');
        setTimeout(function () {
          if (loader.parentNode) loader.parentNode.removeChild(loader);
        }, 350);
        try { sessionStorage.setItem('vq_loaded', '1'); } catch (e) {}
      }
    }

    requestAnimationFrame(frame);
  }

  function initSpaSidebar() {
    // Gate: only convert the stock client-area top nav when its structure is
    // actually present. Class names come from NavigationBar.tsx; if a panel
    // update changes them the gate fails and the default nav is kept.
    var nav = document.querySelector('#app > .w-full.bg-neutral-900.shadow-md.overflow-x-auto');
    var inner = nav && nav.querySelector('.mx-auto');
    if (!nav || !inner || !nav.querySelector('#logo')) return;
    document.body.classList.add('vq-spa-sidebar');
  }

  function initSidebar() {
    var sidebar = document.querySelector('.vq-sidebar');
    var scrim = document.querySelector('.vq-scrim');
    if (!sidebar) return;

    document.addEventListener('click', function (e) {
      var toggle = e.target.closest('[data-vq-toggle]');
      if (toggle) {
        sidebar.classList.toggle('vq-sidebar--open');
        if (scrim) scrim.classList.toggle('vq-scrim--show');
        return;
      }
      if (e.target === scrim || e.target.closest('.vq-nav a')) {
        sidebar.classList.remove('vq-sidebar--open');
        if (scrim) scrim.classList.remove('vq-scrim--show');
      }
    });
  }

  function init() {
    initSidebar();
    initSpaSidebar();
    var fast = false;
    try { fast = sessionStorage.getItem('vq_loaded') === '1'; } catch (e) {}
    runLoader(fast);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  window.VeruTheme = { init: init, runLoader: runLoader, easeOutCubic: easeOutCubic };
})();