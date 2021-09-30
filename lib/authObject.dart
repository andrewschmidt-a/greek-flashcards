class AuthObject {
  bool   isAuthenticated = false;
  String picture = "";
  String name = "";
  String token = "";

  AuthObject.empty(){
  }
  AuthObject(String picture, String name, String token){
      this.isAuthenticated = true;
      this.picture = picture;
      this.name = name;
      this.token = token;
  }
}
