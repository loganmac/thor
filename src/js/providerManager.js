export default function build(portData) {
  const test = function(endpoint, cb){
    return $.ajax(
      url: portData.providersMetaPath, // TODO: where does this come from? gon.providers_meta_path
      data: {
        provider: {endpoint: endpoint}
      }
    ).done(function(data) {
      return cb(data)
    })
    .fail(function(jqXHR, textStatus, errorThrown) {
      if (jqXHR.responseJSON) {
        return cb(jqXHR.responseJSON)
      } else {
        return cb({error: errorThrown})
      }
    });
  };

  const create = function(data, cb) {
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

  const update = function(data, cb) {
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

  const verify = function(provider, fields, endpoint, cb) {
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


  const onCancel = function() {
    window.location = portData.route;
  };

  const addProviderClick = function() {
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
};
