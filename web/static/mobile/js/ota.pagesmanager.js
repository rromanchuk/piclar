;if ((OTA.pages.CURRENT_PAGE_ID !== 'basic') && (typeof OTA.pages[OTA.pages.CURRENT_PAGE_ID] === 'function')) {
    OTA.pages[OTA.pages.CURRENT_PAGE_ID](); // and that's that
}
