import 'whatwg-fetch';
import 'promise-polyfill/src/polyfill';

const Fetcher = {};

Fetcher.get = (path, cb) => (
  fetch(path)
  .then((resp) => resp.json())
  .then(response => cb(response))
);

Fetcher.xmlHttpRequest = (path, action) => {
  const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  return fetch(path, {
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token,
    },
    method: "POST",
    credentials: 'same-origin',
  }).then(resp => resp.json())
    .catch(err => action.err(err))
    .then(response => action.success(response));
};

export default Fetcher;
