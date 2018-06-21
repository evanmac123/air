const WindowHelper = {};

WindowHelper.getDimensions = () => {
  const { documentElement } = document;
  const body = document.getElementsByTagName('body')[0];
  const winWidth = window.innerWidth || documentElement.clientWidth || body.clientWidth;
  const winHeight = window.innerHeight|| documentElement.clientHeight|| body.clientHeight;

  return {winWidth, winHeight};
};

export default WindowHelper;
