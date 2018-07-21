const Faker = require('faker');

const demo = {};

demo.attrs = {
  name: {
    validations: ['req', 'uniq'],
    defaultVal: Faker.random.words,
  },
  email: {
    validations: ['req'],
    defaultVal: Faker.internet.email,
  },
  phone_number: {
    validations: ['req'],
    defaultVal: () => `+${Faker.phone.phoneNumberFormat().replace(/-/g,'')}`,
  },
  public_slug: {
    validations: ['req'],
    defaultVal: () => `public_${Faker.random.number()}`,
  },
};

demo.associations = {
  organization: ['req'],
};

demo.presets = {};

export default demo;
