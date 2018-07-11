import factories from './factories'

const getModelAttrsFromFactory = model => {
  const name = model.split(':')[0];
  const preset = model.split(':')[1];
  return !preset ? factories[name].attrs : Object.assign(factories[name].presets[preset].attrs, factories[name].attrs);
};

const sanitizeAttrs = args => {
  if (!args.model) { return args.data }
  if (args.model.validations.indexOf('uniq') > -1) {
    args.data += ` ${Math.floor(Math.random() * Math.floor(9999))}`;
  }
  return args.data;
};

const sanitizeAssociations = rawData => (
  Object.keys(rawData).reduce((result, modelName) => {
    result[modelName] = rawData[modelName].id;
    return result;
  }, {})
)

const mergeReqAttrs = (rawData, attrs) => (
  Object.keys(attrs).reduce((result, attr) => {
    if (attrs[attr].validations.indexOf('req') > -1 && !rawData[attr]) {
      result[attr] = attrs[attr].defaultVal();
    }
    return result
  }, Object.assign({}, rawData))
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

AirFactory.createParams = (model, rawData = {}, amount) => {
  if (!factories[model.split(':')[0]]) { throw `ERROR: Factory for model '${model}' cannot be found in ./factories` }
  let mergeData;
  const collection = [];
  const attrs = getModelAttrsFromFactory(model);
  amount = amount || 1;
  for (let i = 0; i < amount; i++) {
    mergeData = mergeReqAttrs(rawData, attrs);
    collection.push(Object.keys(mergeData).reduce((result, attr) => {
      let modelAttrs = attrs[attr];
      let data = mergeData[attr];
      result[attr] = (attr === 'associations') ?
        result.associations = sanitizeAssociations(mergeData[attr])
      :
        sanitizeAttrs({ model: attrs[attr], data: mergeData[attr] });
      return result;
    }, { model: model.split(':')[0] }));
  }
  return collection;
};

AirFactory.createModels = (model, resp, amount) => {
  const collection = [];
  for (let i = 0; i < amount; i++) { collection.push(resp[`${model}-${i}`]) }
  return amount === 1 ? collection[0] : collection;
}

export default AirFactory;
