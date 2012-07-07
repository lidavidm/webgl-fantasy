require.config({
    urlArgs: "bust=" + (new Date()).getTime(),

    paths: {
        "use": "plugins/use",
        "cs": "plugins/cs"
    },

    use: {
        "use/Three": {
            attach: "THREE"
        },

        "use/Stats": {
            attach: "Stats"
        },

        "use/jquery": {
            attach: "$"
        },

        "use/jquery-ui": {
            attach: "$"
        },

        "use/underscore": {
            attach: "_"
        },

        "use/backbone": {
            deps: ["use!use/underscore", "use!use/jquery"],
            attach: function(_, $) {
                return Backbone;
            }
        }
    }
});

require(["use!use/jquery", "cs!main"], function($, main) {
    $(document).ready(function(){
        main.main();
    });
});
