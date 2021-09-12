class Env {

  static const hasEnv = bool.hasEnvironment('ENV');

  static String getDomain() {
    return hasEnv
        ? 'kro-presentation-api.herokuapp.com'
        : 'localhost:3000';
  }

  static String getSchema() {
    return hasEnv ? 'https' : 'http';
  }
}
