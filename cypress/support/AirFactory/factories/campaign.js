const Faker = require('faker');

const campaign = {};

campaign.attrs = {
  name: {
    validations: ['req','uniq'],
    defaultVal: Faker.random.words,
  },
  description: {
    validations: ['req'],
    defaultVal: Faker.lorem.sentence,
  },
};

campaign.associations = {
    demo: [],
    population_segment: [],
  };


export default campaign;
