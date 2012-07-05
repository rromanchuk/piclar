;if ((S.env.pageid !== null) && (typeof S.pages[S.env.pageid] === 'function')) {
    S.pages[S.env.pageid](); // and that's that
}
