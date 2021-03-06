import 'whatwg-fetch';
import 'promise-polyfill/src/polyfill';

const Fetcher = {};

Fetcher.get = (path, cb) => (
  fetch(path)
  .then((resp) => resp.json())
  .then(response => cb(response))
);

Fetcher.xmlHttpRequest = (opts) => {
  const method = opts.method || "POST";
  const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  return fetch(opts.path, {
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(opts.params),
    method,
    credentials: 'same-origin',
  }).then(resp => resp.json())
    .then(response => opts.success(response))
    .catch(err => {
      if (opts.err) {
        opts.err(err);
      } else {
        console.error(err);
      }
      throw err;
    });
};

export default Fetcher;
