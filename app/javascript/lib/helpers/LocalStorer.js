const sanitizeItem = item => {
  try {
    return JSON.parse(localStorage.getItem(item));
  } catch(e) {
    return localStorage.getItem(item);
  }
};

const LocalStorer = {};

LocalStorer.setAll = data => {
  Object.keys(data).forEach(key => { localStorage.setItem(key, data[key]); });
};

LocalStorer.getAll = items => (
  items.reduce((result, item) => {
    /* eslint-disable no-param-reassign */
    result[item] = sanitizeItem(item);
    /* eslint-enable */
    return result;
  }, {})
);

LocalStorer.get = item => sanitizeItem(item);

export default LocalStorer;
