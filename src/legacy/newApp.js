export default function build(portData) {
  var app = new nanobox.AppLaunch($(portData.node));

  function onCancel() {
    return window.location = portData.route;
  };

  function onLaunchApp(data, cb) {
    return $.ajax({
      type: "POST",
      url: portData.newAppUrl,
      data: {
        app: {
          name: data.name
        },
        stack: {
          provider_account_id: data.provider_account_id,
          region: data.region
        }
      }
    }).done(function(data) {
      if (data.error) {
        return cb(data);
      } else {
        return window.location = data.app_path;
      }
    });
  };

  function onValidateName(name, cb) {
    return $.ajax({
      type: "POST",
      url: portData.validateAppUrl,
      data: {
        app: {
          name: name
        }
      }
    }).always(function(data) {
      return cb(data);
    });
  };

  function test(endpoint, cb) {
    return $.ajax({
          url: portData.providersMetaUrl,
          data: {
            provider: {
              endpoint: endpoint
            }
          }
        }

      ).done(function(data) {
        return cb(data)
      })
      .fail(function(jqXHR, textStatus, errorThrown) {
        if (jqXHR.responseJSON) {
          return cb(jqXHR.responseJSON)
        } else {
          return cb({
            error: errorThrown
          })
        }
      });
  };

  function create(data, cb) {
    return $.ajax({
      type: "POST",
      url: portData.createProviderAccountUrl,
      data: {
        provider: {
          id: data.provider.id,
          endpoint: data.endpoint
        },
        provider_account: {
          name: data.name,
          credentials: data.authentication,
          default_region: data.defaultRegion
        }
      }
    }).done(function(r_data) {
      return window.location = portData.route;
    }).fail(function(jqXHR, textStatus, errorThrown) {
      if (jqXHR.responseJSON) {
        return cb(jqXHR.responseJSON);
      } else {
        return cb({
          error: errorThrown
        });
      }
    });
  };

  function verify(provider, fields, endpoint, cb) {
    return $.ajax({
      url: portData.verifyProviderAccountUrl,
      data: {
        provider: {
          id: provider.id,
          endpoint: endpoint
        },
        provider_account: {
          credentials: fields
        }
      }
    }).done(function(data) {
      return cb(data);
    }).fail(function(jqXHR, textStatus, errorThrown) {
      if (jqXHR.responseJSON) {
        return cb(jqXHR.responseJSON);
      } else {
        return cb({
          error: errorThrown
        });
      }
    });
  };

  if (portData.providersWithAccounts.length > 0) {
    var appCreateConfig;
    appCreateConfig = {
      providers: portData.providersWithAccounts,
      appLaunchCb: onLaunchApp,
      validateNameCb: onValidateName,
      onCancel: onCancel
    };
    return app.createAppLauncher(appCreateConfig);
  } else {
    var providerConfig;
    providerConfig = {
      onCancel: onCancel,
      officialProviders: portData.officialProviders,
      customProviders: portData.customProviders,
      endpointTester: test,
      addProviderCb: create,
      verifyAccount: verify,
      hasAccounts: portData.providersWithAccounts.length > 0
    };
    return app.addProvider(providerConfig);
  }
}
