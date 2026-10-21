/* bridge.games: tap a screenshot to see it whole. Each one sits in
   <a class="zoom" href="/images/…">, so without this script the link just
   opens the image. No library, nothing stored, nothing counted: GoatCounter
   only counts elements carrying data-goatcounter-click, and these never do. */
(function () {
  var links = document.querySelectorAll('a.zoom');
  if (!links.length || typeof HTMLDialogElement !== 'function') return;

  var box = document.createElement('dialog');
  box.className = 'zoom-box';
  box.setAttribute('aria-label', 'Enlarged screenshot');
  box.innerHTML = '<img alt=""><button type="button" class="zoom-close" aria-label="Close">&times;</button>';
  document.body.appendChild(box);
  var big = box.querySelector('img');
  var shut = box.querySelector('.zoom-close');
  var opener = null;

  // Any press inside closes it: the picture, the backdrop, or the ×.
  box.addEventListener('click', function () { box.close(); });
  // Esc closes a modal dialog by itself; every way out lands here.
  box.addEventListener('close', function () {
    document.documentElement.classList.remove('zoom-open');
    big.removeAttribute('src');
    if (opener) opener.focus();
  });

  Array.prototype.forEach.call(links, function (a) {
    a.setAttribute('aria-haspopup', 'dialog');
    a.addEventListener('click', function (e) {
      // A modified click still opens the image in a new tab, as a link does.
      if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      e.preventDefault();
      var img = a.querySelector('img');
      opener = a;
      big.alt = img ? img.alt : '';
      big.src = a.href;
      document.documentElement.classList.add('zoom-open');
      box.showModal();
      shut.focus();
    });
  });
})();
