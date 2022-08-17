import { getSessionToken } from "@shopify/app-bridge-utils";

function ajax_token_function() {
  $.ajaxSetup({
    beforeSend: function (xhr, data) {
      if(!data.url.includes("https://app.curiermanager.ro")){
        if (window.sessionToken == undefined) {
          getSessionToken(app).then((token) => {
            window.sessionToken = token;
            xhr.setRequestHeader("Authorization", "Bearer " + window.sessionToken);
          });
        }
        else {
          xhr.setRequestHeader("Authorization", "Bearer " + window.sessionToken);
        }
      }
    }
  });
};

export { ajax_token_function };
