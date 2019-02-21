/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */
import React, { Component } from 'react';
import { StyleSheet, Text, TouchableHighlight, View } from 'react-native';

import { LoginManager } from 'react-native-line-login'

export default class App extends Component {
    _handleClickLogin() {
        LoginManager.login()
            .then( ( user ) => {
                console.log( user )
            } )
            .catch( ( err ) => {
                console.log( err )
            } )
    }

    _handleClickUserProfile() {
        LoginManager.getUserProfile()
            .then( ( user ) => {
                console.log( user )
            } )
            .catch( ( err ) => {
                console.log( err )
            } )
    }

    _handleClickLogout() {
        LoginManager.logout()
    }

    render() {
        return (
            <View style={styles.container}>
                <Text style={styles.welcome}>
                    Welcome to React Native!
                </Text>
                <Text style={styles.instructions}>
                    To get started, edit index.android.js
                </Text>
                <Text style={styles.instructions}>
                    Double tap R on your keyboard to reload,{'\n'}
                    Shake or press menu button for dev menu
                </Text>

                <TouchableHighlight
                    style={styles.button}
                    onPress={this._handleClickLogin}>
                    <View>
                        <Text>Login</Text>
                    </View>
                </TouchableHighlight>

                <TouchableHighlight
                    style={styles.button}
                    onPress={this._handleClickUserProfile}>
                    <View>
                        <Text>User Profile</Text>
                    </View>
                </TouchableHighlight>

                <TouchableHighlight
                    style={styles.button}
                    onPress={this._handleClickLogout}>
                    <View>
                        <Text>Logout</Text>
                    </View>
                </TouchableHighlight>
            </View>
        );
    }
}

const styles = StyleSheet.create( {
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
} );