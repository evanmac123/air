import factories from './factories'

const sanitizeAttrs = args => {
  if (!args.model) { return args.data }
  if (args.model.validations.indexOf('uniq') > -1) {
    args.data += ` ${Math.floor(Math.random() * Math.floor(9999))}`;
  }
  return args.data;
};

const mergeReqAttrs = (rawData, attrs) => (
  Object.keys(attrs).reduce((result, attr) => {
    if (attrs[attr].validations.indexOf('req') > -1 && !rawData[attr]) {
      result[attr] = attrs[attr].defaultVal();
    }
    return result
  }, rawData)
)

const AirFactory = {};

AirFactory.createRakeDigest = (model, rawData, amount) => {
  const collection = [];
  const attrs = factories[model].attrs;
  let result = '';
  amount = amount || 1;
  for (let i = 0; i < amount; i++) {
    result += `${model}, `
    Object.keys(rawData).forEach(attr => {
      let model = attrs[attr];
      let data = rawData[attr];
      result += `${attr}=${sanitizeAttrs({ model, attr, data })}, `;
    });
    collection.push(result.slice(0, -2));
  }
  return amount === 1 ? collection[0] : collection;
};

AirFactory.createParams = (model, rawData, amount) => {
  const collection = [];
  const attrs = factories[model].attrs;
  amount = amount || 1;
  for (let i = 0; i < amount; i++) {
    rawData = mergeReqAttrs(rawData, attrs);
    collection.push(Object.keys(rawData).reduce((result, attr) => {
      let modelAttrs = attrs[attr];
      let data = rawData[attr];
      result[attr] = sanitizeAttrs({ model: attrs[attr], data: rawData[attr] });
      return result;
    }, { model }));
  }
  debugger
  return collection;
};

AirFactory.createModels = (model, resp, amount) => {
  const collection = [];
  for (let i = 0; i < amount; i++) { collection.push(resp[`${model}-${i}`]) }
  return amount === 1 ? collection[0] : collection;
}

export default AirFactory;
