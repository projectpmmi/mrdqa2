import 'package:flutter/material.dart';
import 'package:mrdqa_tool/services/SecurityManager.dart';

/**
 * Config object to be stored locally but some settings to be pulled from DHIS2.
 */
class Config{
  final SecurityManager _securityManager = new SecurityManager();
  String _baseUrl = 'https://play.dhis2.org/2.36.8';
  String _username = 'admin'; //to be encrypted and stored locally
  String _password; //to be encrypted and stored locally
  String _level = '1';
  String _program;
  String _programName;
  String _programPeriodType;
  Config() {
    _password = _securityManager.encrypt('district').base16;
    print('_password');
    print(_password);
    print("^^^^^");
  }
  String getBaseUrl() {return this._baseUrl;}
  String getUsername() => this._username;
  String getPassword() => this._password;
  String getLevel() => _level;
  String getProgram() => _program;
  String getProgramName() => _programName;
  String getProgramPeriodType() => _programPeriodType;

  setBaseUrl(String baseUrl){
    _baseUrl = baseUrl;
  }

  setUsername(String username) {
    _username = username;
  }

  setPassword(String password) {
    _password = password;
  }
  setLevel(String level) {
    _level = level;
  }
  setProgram(String program) {
    _program = program;
  }
  setProgramName(String programName) {
    _programName = programName;
  }
  setProgramPeriodType(String programPeriodType) {
    _programPeriodType = programPeriodType;
  }
  String toString(){

    return 'Config: Level: $_level, Program: $_program, Program Name: $_programName, Period Type: $_programPeriodType';
  }
}