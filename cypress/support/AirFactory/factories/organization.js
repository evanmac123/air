const Faker = require('faker');

const organization = {};

organization.attrs = {
  name: {
    validations: ['req', 'uniq'],
    defaultVal: () => `${Faker.name.jobDescriptor()} ${Faker.name.jobArea()}`,
  },
};

organization.presets = {
  complete: {
    attrs: {
      num_employees: {
        validations: ['req'],
        defaultVal: () => 5000,
      }
    }
  }
}

export default organization;
