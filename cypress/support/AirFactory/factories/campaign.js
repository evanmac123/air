const campaign = {};

campaign.attrs = {
  associations: {
    demo: [],
    population_segment: [],
  },
  name: {
    validations: ['req','uniq'],
    defaultVal: 'Test Campaign',
  },
  description: {
    validations: ['req'],
    defaultVal: 'Campaign generated for E2E testing',
  }
};

export default campaign;
