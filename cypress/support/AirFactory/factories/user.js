const Faker = require('faker');

const user = {};

user.attrs = {
  name: {
    validations: ['req'],
    defaultVal: Faker.name.findName,
  },
  password: {
    validations: ['req'],
    defaultVal: () => 'password',
  },
  email: {
    validations: ['req'],
    defaultVal: Faker.internet.email,
  },
  suggestion_box_intro_seen: {
    validations: ['req'],
    defaultVal: () => true,
  },
  user_submitted_tile_intro_seen: {
    validations: ['req'],
    defaultVal: () => true,
  },
  manage_access_prompt_seen: {
    validations: ['req'],
    defaultVal: () => true,
  },
};

user.associations = {
  demo: ['req'],
  user_intro: [],
};

user.presets = {
  clientAdmin: {
    attrs: {
      is_client_admin: {
        validations: ['req'],
        defaultVal: () => true,
      },
      session_count: {
        validations: ['req'],
        defaultVal: () => 5,
      },
      accepted_invitation_at: {
        validations: ['req'],
        defaultVal: Date.now,
      },
    },
  },
};

export default user;
