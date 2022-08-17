import { getSessionToken } from "@shopify/app-bridge-utils";
import { ajax_token_function } from "./ajax_request_token";

const SESSION_TOKEN_REFRESH_INTERVAL = 5000; // Request a new token every 5s

async function retrieveToken(app) {
  window.sessionToken = await getSessionToken(app);
}

function keepRetrievingToken(app) {
  setInterval(() => {
    retrieveToken(app);
  }, SESSION_TOKEN_REFRESH_INTERVAL);
}

document.addEventListener("turbolinks:request-start", function (event) {
  var xhr = event.data.xhr;
  xhr.setRequestHeader("Authorization", "Bearer " + window.sessionToken);
  ajax_token_function();
});

document.addEventListener("turbolinks:render", function () {
  $("form, a[data-method=delete]").on("ajax:beforeSend", function (event) {
    const xhr = event.detail[0];
    xhr.setRequestHeader("Authorization", "Bearer " + window.sessionToken);
    ajax_token_function();
  });
});

document.addEventListener('DOMContentLoaded', async () => {
  // Wait for a session token before trying to load an authenticated page
  await retrieveToken(app);

  // Keep retrieving a session token periodically
  keepRetrievingToken(app);

  // Redirect to the requested page when DOM loads
  var isInitialRedirect = true;
  redirectThroughTurbolinks(isInitialRedirect);

  document.addEventListener("turbolinks:load", function (event) {
    redirectThroughTurbolinks();
  });
});

// The helper method navigates your app using Turbolinks
function redirectThroughTurbolinks(isInitialRedirect = false) {
  var validLoadPath = '/shopify_app';
  var shouldRedirect = false;

  switch (isInitialRedirect) {
    case true:
      shouldRedirect = validLoadPath;
      break;
    case false:
      shouldRedirect = validLoadPath && data.loadPath !== "/shopify_app";
      break;
  }
  if (shouldRedirect) Turbolinks.visit(data.loadPath);
}
