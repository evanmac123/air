const SanitizeVarForRuby = variable => (
  variable.replace(/\.?([A-Z]+)/g, (x,y) => `_${y.toLowerCase()}`).replace(/^_/, "")
);

export default SanitizeVarForRuby;
