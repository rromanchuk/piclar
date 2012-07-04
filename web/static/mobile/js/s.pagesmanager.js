;if ((S.pages.CURRENT_PAGE_ID !== 'basic') && (typeof S.pages[S.pages.CURRENT_PAGE_ID] === 'function')) {
    S.pages[S.pages.CURRENT_PAGE_ID](); // and that's that
}
