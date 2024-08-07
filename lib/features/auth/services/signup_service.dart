import 'package:limcad/features/auth/models/login_response.dart';
import 'package:limcad/features/auth/models/signup_request.dart';
import 'package:limcad/features/auth/models/signup_response.dart';
import 'package:limcad/features/onboarding/get_started.dart';
import 'package:limcad/resources/api/api_client.dart';
import 'package:limcad/resources/api/base_response.dart';
import 'package:limcad/resources/api/response_code.dart';
import 'package:limcad/resources/models/change_profile_response.dart';
import 'package:limcad/resources/models/general_response.dart';
import 'package:limcad/resources/models/no_object_response.dart';
import 'package:limcad/resources/api/route.dart';
import 'package:limcad/resources/locator.dart';
import 'package:limcad/resources/models/profile.dart';
import 'package:limcad/resources/models/state_model.dart';
import 'package:limcad/resources/storage/base_preference.dart';
import 'package:stacked/stacked.dart';

class AuthenticationService with ListenableServiceMixin {
  final apiService = locator<APIClient>();

  AuthenticationService() {
    //3
    listenToReactiveValues([_profile]);
  }

  //2
  ProfileResponse? _profile;

  //profile
  ProfileResponse? get profile => _profile;

  Future<BaseResponse<RegistrationResponse>> signUp(
      SignupRequest? signupRequest) async {
    var signupResponse = await apiService.request(
        route: ApiRoute(ApiType.registerUser),
        data: signupRequest?.toJson(),
        create: () => BaseResponse<RegistrationResponse>(
            create: () => RegistrationResponse()));
    return signupResponse.response;
  }

  Future<BaseResponse<LoginResponse>> login(
      SignupRequest? signupRequest, UserType? userType) async {
    final loginRequest = {
      "email": signupRequest?.email,
      "password": signupRequest?.password,
      "userType": userType?.name.toUpperCase()
    };

    var loginResponse = await apiService.request(
        route: ApiRoute(ApiType.login),
        data: loginRequest,
        create: () =>
            BaseResponse<LoginResponse>(create: () => LoginResponse()));

    return loginResponse.response;
  }

  Future<BaseResponse<GeneralResponse>> requestOtp(
      SignupRequest? signupRequest, UserType? userType) async {
    final otprequest = {
      "email": signupRequest?.email,
      "userType": userType?.name.toUpperCase()
    };
    var loginResponse = await apiService.request(
        route: ApiRoute(ApiType.requestEmailOtp),
        data: otprequest,
        create: () =>
            BaseResponse<GeneralResponse>(create: () => GeneralResponse()));
    return loginResponse.response;
  }

  Future<BaseResponse<GeneralResponse>> requestResetPasswordCode(
      UserType? userType, String? email) async {
    final request = {"email": email, "userType": userType?.name.toUpperCase()};
    var response = await apiService.request(
      route: ApiRoute(ApiType.passwordResetCodeRequest),
      data: request,
      create: () =>
          BaseResponse<GeneralResponse>(create: () => GeneralResponse()),
    );

    return response.response;
  }

  Future<BaseResponse<ChangeProfileResponse>> changeProfile(
      String? name, String? phoneNumber, String? email) async {
    final Map<String, dynamic> request = {};
    if (name != null && name.isNotEmpty) {
      request['name'] = name;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      request['phoneNumber'] = phoneNumber;
    }
    if (email != null && email.isNotEmpty) {
      request['email'] = email;
    }

    var response = await apiService.request(
      route: ApiRoute(ApiType.updateProfile),
      data: request,
      create: () => BaseResponse<ChangeProfileResponse>(
          create: () => ChangeProfileResponse()),
    );

    return response.response;
  }

  Future<BaseResponse<LoginResponse>> validateOtp(
      String? email, String? otp, String userType) async {
    final otprequest = {
      "email": email,
      "code": otp,
      "userType": userType.toUpperCase()
    };
    var loginResponse = await apiService.request(
        route: ApiRoute(ApiType.validateEmailOtp),
        data: otprequest,
        create: () =>
            BaseResponse<LoginResponse>(create: () => LoginResponse()));
    return loginResponse.response;
  }

  Future<BaseAPIListPaginationResponse<StateResponse>> getStates() async {
    var response = await apiService.request(
        route: ApiRoute(ApiType.states, routeParams: "offset=0&size=40"),
        create: () => BaseAPIListPaginationResponse<StateResponse>(
            create: () => StateResponse()));
    return response.response;
  }

  Future<BaseAPIListResponse<LGAResponse>> getLGAs(String? stateId) async {
    var response = await apiService.request(
        route: ApiRoute(ApiType.lgas, routeParams: "$stateId"),
        create: () =>
            BaseAPIListResponse<LGAResponse>(create: () => LGAResponse()));
    return response.response;
  }

  Future<BaseResponse<ProfileResponse>> getProfile() async {
    var response = await apiService.request(
        route: ApiRoute(ApiType.profile),
        create: () =>
            BaseResponse<ProfileResponse>(create: () => ProfileResponse()));
    _profile = response.response.data;
    if (response.response.status == ResponseCode.success) {
      BasePreference basePreference = await BasePreference.getInstance();
      basePreference.saveProfileDetails(_profile!);
    }
    return response.response;
  }
}
