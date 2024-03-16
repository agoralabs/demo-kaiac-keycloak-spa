const baseUrl = 'http://localhost:8081/';

export default {
  baseUrl: baseUrl,
  token: {
    username: 'alice',
    password: 'password',
    grant_type: 'password',
    client_id: 'test-cli',
    realmName: 'quickstart'
  },
  adminClient: {
    baseUrl: baseUrl,
    realmName: 'master',
    username: 'admin',
    password: 'keycloak',
    grantType: 'password',
    clientId: 'admin-cli'
  }
};
