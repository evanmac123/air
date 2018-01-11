/*
This file is used as a bridge between Sprockets/Legacy JS and ES6.  JS code that needs to be initialized based on a particular entry point, that is not Vue App, should be initialized in this file.
*/

export default function dispatcher() {
  return "Dispatcher init...";
}
