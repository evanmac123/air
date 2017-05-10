var Airbo = window.Airbo || {};

Airbo.PubSub = (function(){
  var topics = $({});

  function subscribe(topic, handler) {
    topics.on(topic, handler);
  }

  function unsubscribe(topic) {
    topics.off(topic);
  }

  function publish(topic, handlerParams) {
    handlerParams = handlerParams || {};

    topics.trigger(topic, handlerParams);
  }

  return {
    subscribe: subscribe,
    unsubscribe: unsubscribe,
    publish: publish
  };

}());


// Basic example:

// var handler = function(event, options) {
//   console.log(options.a + options.b + options.c);
// };
//
// Airbo.PubSub.subscribe("/some/topic", handler);
//
// Airbo.PubSub.publish("/some/topic", { a: "a", b: "b", c: "c" });
// // logs: abc
//
// Airbo.PubSub.unsubscribe("/some/topic"); // Unsubscribe all handlers for this topic
