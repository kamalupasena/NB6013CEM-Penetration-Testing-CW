(function () {
  const assessmentPages = /^#\/(?:score-board|coding-challenges?|hints?)(?:[/?#]|$)/i;
  function keepShopView() {
    if (assessmentPages.test(window.location.hash)) {
      window.location.replace(window.location.pathname + window.location.search + '#/');
    }
  }
  keepShopView();
  window.addEventListener('hashchange', keepShopView);
})();
