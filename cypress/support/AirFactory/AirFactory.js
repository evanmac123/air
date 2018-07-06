import factories from './factories'

const sanitizeAttrs = args => {
  let data = args.data || null;
  if (!args.model) { return data }
  if (args.model.validations.indexOf('req') > -1 && !!data) {
    data = args.model.defaultVal
  }
  if (args.model.validations.indexOf('uniq') > -1) {
    data += ` ${Math.floor(Math.random() * Math.floor(9999))}`;
  }
  return data;
};

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

export default AirFactory;
