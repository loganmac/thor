export default function build(portData) {
  function onCancel() {
    window.location = portData.route;
  };

  function test(endpoint, cb) {
    return $.ajax({
          url: portData.providersMetaPath,
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
      url: portData.createUrl,
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

  function update(data, cb) {
    return $.ajax({
      type: "PATCH",
      url: portData.updateUrl + "/" + data.accountId,
      data: {
        provider: {
          id: data.providerId,
          endpoint: data.endpoint
        },
        provider_account: {
          name: data.name,
          credentials: data.authFields,
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


    function verify(provider, fields, endpoint, cb) {
      return $.ajax({
        url: portData.verifyUrl,
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

    function addProviderClick() {
      $('.provider-list').empty();
      let config = {
        onCancel: onCancel,
        officialProviders: portData.officialProviders,
        customProviders: portData.customProviders,
        endpointTester: test,
        addProviderCb: create,
        verifyAccount: verify,
        hasAccounts: portData.providerAccounts.length > 0
      };

      if (!this.app) { // this is to debounce?
        this.app = new nanobox.AppLaunch(portData.node);
        return this.app.addProvider(config);
      }
    };

    let config = {
      accounts: portData.providerAccounts,
      endpointTester: test,
      updateProvider: update,
      verifyAccount: verify,
      deleteAccount: destroy,
      addProviderClick: addProviderClick
    };
    new nanobox.ProviderAccounts(portData.node, config)
  }
}
