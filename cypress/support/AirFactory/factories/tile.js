const Faker = require('faker');

const tile = {};

tile.attrs = {
  headline: {
    validations: ['req'],
    defaultVal: Faker.random.word,
  },
  require_images: {
    validations: ['req'],
    defaultVal: () => ( false ),
  },
  supporting_content: {
    validations: ['req'],
    defaultVal: Faker.lorem.sentence,
  },
  status: {
    validations: ['req'],
    defaultVal: () => ( 'active' )
  },
  question: {
    validations: ['req'],
    defaultVal: Faker.lorem.words,
  },
  question_type: {
    validations: ['req'],
    defaultVal: () => ( 'quiz' )
  },
  question_subtype: {
    validations: ['req'],
    defaultVal: () => ( 'multiple_choice' )
  },
  remote_media_url: {
    validations: ['req'],
    defaultVal: () => ( '/images/cov1.jpg' )
  }
};

tile.associations = {
    demo: ['req'],
    campaign: [],
  };

export default tile;
