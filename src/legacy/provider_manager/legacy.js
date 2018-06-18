!function e(t,i,n){function a(d,o){if(!i[d]){if(!t[d]){var r="function"==typeof require&&require;if(!o&&r)return r(d,!0);if(s)return s(d,!0);var c=new Error("Cannot find module '"+d+"'");throw c.code="MODULE_NOT_FOUND",c}var l=i[d]={exports:{}};t[d][0].call(l.exports,function(e){var i=t[d][1][e];return a(i?i:e)},l,l.exports,e,t,i,n)}return i[d].exports}for(var s="function"==typeof require&&require,d=0;d<n.length;d++)a(n[d]);return a}({1:[function(e,t,i){var n,a,s,d=function(e,t){return function(){return e.apply(t,arguments)}};s=e("provider-list"),a=e("provider-edit"),n=function(){function e(e,t){this.$el=e,this.data=t,this.hideAccount=d(this.hideAccount,this),this.showAccount=d(this.showAccount,this),this.accountList=new s(this.$el,this.data.accounts,this.showAccount,this.data.addProviderClick)}return e.prototype.showAccount=function(e){return this.accountList.hide(),this.account=new a(this.$el,this.getAccountData(e),this.data.endpointTester,this.data.verifyAccount,this.data.updateProvider,this.data.deleteAccount,this.hideAccount)},e.prototype.hideAccount=function(){return this.account.destroy(),this.account=null,this.accountList.show()},e.prototype.getAccountData=function(e){var t,i,n,a;for(a=this.data.accounts,i=0,n=a.length;i<n;i++)if(t=a[i],e===t.id)return t},e}(),window.nanobox||(window.nanobox={}),nanobox.ProviderAccounts=n},{"provider-edit":2,"provider-list":3}],2:[function(e,t,i){var n,a,s,d;a=e("jade/provider-edit"),s=e("jade/provider-specific-vals"),d=e("jade/select"),t.exports=n=function(){function e(e,t,i,n,s,d,o){this.$el=e,this.accountData=t,this.testEndpoint=i,this.verifyAccount=n,this.save=s,this.deleteAccount=d,this.provider=this.accountData.provider,this.validEndpoint=this.provider.endpoint,null!=this.accountData.provider.endpoint&&(this.accountData.isCustom=!0),this.$node=$(a(this.accountData)),this.$el.append(this.$node),this.$testEndpointBtn=$("#test-endpoint",this.$node),this.$saveBtn=$("#save",this.$node),$("#cancel",this.$node).on("click",o),this.$saveBtn.on("click",function(e){return function(t){return e.onSaveClick()}}(this)),$("#delete-account",this.$node).on("click",function(e){return function(t){return e.deleteAccountClick(t)}}(this)),$("#endpoint",this.$node).on("input",function(e){return function(t){return e.onEndpointEdit(t.currentTarget.value)}}(this)),this.$testEndpointBtn.on("click",function(e){return function(t){return e.endpoint=$("#endpoint",e.$node).val(),e.onTestEndpoint(e.endpoint)}}(this)),this.$authFields=$(".provider-specific",this.$node),this.addAuthFields(),castShadows(this.$node)}return e.prototype.onEndpointEdit=function(e){return this.validEndpoint=null,e!==this.accountData.endpoint?(this.$testEndpointBtn.removeClass("hidden"),this.$testEndpointBtn.removeClass("success"),this.$testEndpointBtn.text("Test Endpoint"),this.$saveBtn.addClass("disabled")):(this.$testEndpointBtn.addClass("hidden"),this.$saveBtn.removeClass("disabled"))},e.prototype.onTestEndpoint=function(e){return this.$testEndpointBtn.addClass("ing"),this.$testEndpointBtn.text("Testing..."),$(".errors",this.$node).addClass("hidden"),this.testEndpoint(e,function(t){return function(i){return t.$testEndpointBtn.removeClass("ing"),i.error?(t.validEndpoint=null,t.addError(i.error),t.$testEndpointBtn.text("Test Endpoint")):(t.$saveBtn.removeClass("disabled"),t.provider=i.provider,t.validEndpoint=e,t.$testEndpointBtn.text("Success!"),t.$testEndpointBtn.addClass("success"),t.addAuthFields())}}(this))},e.prototype.onSaveClick=function(){var e,t,i,n,a;for(this.clearErrors(),this.$saveBtn.text("Verifying").addClass("ing"),e={},a=$(".auth-field",this.$node),t=0,n=a.length;t<n;t++)i=a[t],e[i.getAttribute("data-key")]=i.value;return this.verifyAccount(this.provider,e,this.validEndpoint,function(t){return function(n){var a,s,d,o;if(n.error)return t.addError(n.error),t.$saveBtn.text("Save").removeClass("ing");for(t.$saveBtn.text("Saving"),s={},a=$("input:not(.auth-field)",t.$node),d=0,o=a.length;d<o;d++)i=a[d],s[i.getAttribute("data-key")]=i.value;return s.authFields=e,s.defaultRegion=$("#regions select",t.$node)[0].value,s.accountId=t.accountData.id,s.providerId=t.accountData.provider.id,t.save(s,function(e){return e.error?(t.$saveBtn.text("Save").removeClass("ing"),t.addError(e.error)):(t.$saveBtn.text("Saved!").removeClass("ing").addClass("success"),t.refreshPage())})}}(this))},e.prototype.deleteAccountClick=function(e){return e.currentTarget.className.indexOf("confirm")===-1?e.currentTarget.className=e.currentTarget.className+" confirm":this.deleteAccount(this.accountData.id,this.accountData.provider.id,function(e){return function(t){return t.error?e.addError(t.error):e.refreshPage()}}(this))},e.prototype.addAuthFields=function(){var e,t,i,n,a,o,r,c,l,u;for(this.$authFields.empty(),c=this.provider.authFields,n=0,o=c.length;n<o;n++)i=c[n],null==i.val&&(i.val="");for(e=$(s({account:this.accountData,provider:this.provider})),this.$authFields.append(e),l=this.provider.regions,a=0,r=l.length;a<r;a++)u=l[a],u.id===this.accountData.defaultRegion.id&&(u.selected=!0);return t=$(d({items:this.provider.regions})),t.val(this.accountData.defaultRegion.id),$("#regions",e).append(t),lexify(this.$el)},e.prototype.addError=function(e){return $(".errors",this.$node).text(e).removeClass("hidden")},e.prototype.clearErrors=function(){return $(".errors",this.$node).addClass("hidden")},e.prototype.refreshPage=function(){return setTimeout("location.reload(true);",1e3)},e.prototype.destroy=function(){return $("#cancel",this.$node).off(),$("#save",this.$node).off(),this.$node.remove()},e}()},{"jade/provider-edit":4,"jade/provider-specific-vals":6,"jade/select":7}],3:[function(e,t,i){var n,a;a=e("jade/provider-list"),t.exports=n=function(){function e(e,t,i,n){this.$node=$(a({accounts:t})),e.append(this.$node),castShadows(),$(".button").on("click",function(e){return i(e.currentTarget.getAttribute("data-id"))}),$("#add-provider-account",this.$node).on("click",n)}return e.prototype.hide=function(){return this.$node.css({display:"none"})},e.prototype.show=function(){return this.$node.css({display:"initial"})},e}()},{"jade/provider-list":5}],4:[function(e,t,i){t.exports=function(e){var t,i=[],n=e||{};return function(e,n,a,s,d){i.push('<div class="blue-item provider-edit lexi-blue lexi"><div class="errors hidden">Some Error</div><div class="icon"><img'+jade.attr("data-src",""+s.icon,!0,!1)+' scalable="true" class="shadow-icon"/></div><div class="vals"><div class="standard"><div class="val"><div class="label">Account Name</div><input'+jade.attr("value",""+a,!0,!1)+' data-key="name"/></div>'),n&&i.push('<div class="val"><div class="label">Endpoint</div><input id="endpoint"'+jade.attr("value",""+s.endpoint,!0,!1)+' data-key="endpoint"/><div id="test-endpoint" class="button lifecycle hidden">Test Endpoint</div></div>'),i.push('</div><div class="provider-specific"></div></div><div class="save-section">'),0==e.length&&i.push('<div id="delete-account" class="delete"> <img data-src="close-x" class="shadow-icon"/><div class="txt">Delete Account </div></div>'),i.push('<div id="cancel" class="cancel">Cancel</div><div id="save" class="button lifecycle">Save </div></div>'),0!=e.length&&(i.push('<div class="sub-items"><h2>Apps launched on this account</h2>'),function(){var n=e;if("number"==typeof n.length)for(var a=0,s=n.length;a<s;a++){var d=n[a];i.push('<div class="item"><div class="name">'+jade.escape(null==(t=d.name)?"":t)+"</div><a"+jade.attr("href",""+d.managePath,!0,!1)+' class="manage">Manage</a><a'+jade.attr("href",""+d.removePath,!0,!1)+">Remove</a></div>")}else{var s=0;for(var a in n){s++;var d=n[a];i.push('<div class="item"><div class="name">'+jade.escape(null==(t=d.name)?"":t)+"</div><a"+jade.attr("href",""+d.managePath,!0,!1)+' class="manage">Manage</a><a'+jade.attr("href",""+d.removePath,!0,!1)+">Remove</a></div>")}}}.call(this),i.push("</div>")),i.push("</div>")}.call(this,"apps"in n?n.apps:"undefined"!=typeof apps?apps:void 0,"isCustom"in n?n.isCustom:"undefined"!=typeof isCustom?isCustom:void 0,"name"in n?n.name:"undefined"!=typeof name?name:void 0,"provider"in n?n.provider:"undefined"!=typeof provider?provider:void 0,"undefined"in n?n.undefined:void 0),i.join("")}},{}],5:[function(e,t,i){t.exports=function(e){var t,i=[],n=e||{};return function(e,n){i.push('<div class="blue-list">'),function(){var n=e;if("number"==typeof n.length)for(var a=0,s=n.length;a<s;a++){var d=n[a];i.push('<div class="item"><div class="icon"><img'+jade.attr("data-src",""+d.provider.icon,!0,!1)+' scalable="true" class="shadow-icon"/></div><div class="info"><div class="name">'+jade.escape(null==(t=d.name)?"":t)+'</div><div class="details"><div class="label">Default Region</div><div class="val">'+jade.escape(null==(t=d.defaultRegion.name)?"":t)+'</div><div class="label">TotalApps</div><div class="val">'+jade.escape(null==(t=d.apps.length)?"":t)+"</div></div></div><div"+jade.attr("data-id",""+d.id,!0,!1)+' class="button">Manage</div></div>')}else{var s=0;for(var a in n){s++;var d=n[a];i.push('<div class="item"><div class="icon"><img'+jade.attr("data-src",""+d.provider.icon,!0,!1)+' scalable="true" class="shadow-icon"/></div><div class="info"><div class="name">'+jade.escape(null==(t=d.name)?"":t)+'</div><div class="details"><div class="label">Default Region</div><div class="val">'+jade.escape(null==(t=d.defaultRegion.name)?"":t)+'</div><div class="label">TotalApps</div><div class="val">'+jade.escape(null==(t=d.apps.length)?"":t)+"</div></div></div><div"+jade.attr("data-id",""+d.id,!0,!1)+' class="button">Manage</div></div>')}}}.call(this),i.push('<div id="add-provider-account" class="add-new"><img data-src="big-add" class="shadow-icon"/><div class="txt">Add Account</div></div></div>')}.call(this,"accounts"in n?n.accounts:"undefined"!=typeof accounts?accounts:void 0,"undefined"in n?n.undefined:void 0),i.join("")}},{}],6:[function(e,t,i){t.exports=function(e){var t,i=[],n=e||{};return function(e,n){i.push('<div class="val"><div class="label">Default Region</div><div id="regions"></div></div>'),function(){var n=e.authFields;if("number"==typeof n.length)for(var a=0,s=n.length;a<s;a++){var d=n[a];i.push('<div class="val"><div class="label">'+jade.escape(null==(t=d.label)?"":t)+"</div><input"+jade.attr("value",""+d.val,!0,!1)+jade.attr("data-key",""+d.key,!0,!1)+' class="auth-field"/></div>')}else{var s=0;for(var a in n){s++;var d=n[a];i.push('<div class="val"><div class="label">'+jade.escape(null==(t=d.label)?"":t)+"</div><input"+jade.attr("value",""+d.val,!0,!1)+jade.attr("data-key",""+d.key,!0,!1)+' class="auth-field"/></div>')}}}.call(this)}.call(this,"provider"in n?n.provider:"undefined"!=typeof provider?provider:void 0,"undefined"in n?n.undefined:void 0),i.join("")}},{}],7:[function(e,t,i){t.exports=function(e){var t,i=[],n=e||{};return function(e,n,a){i.push("<select"+jade.cls([""+e],[!0])+">"),function(){var e=n;if("number"==typeof e.length)for(var a=0,s=e.length;a<s;a++){var d=e[a];null!=d.group?(i.push("<optgroup"+jade.attr("label",""+d.group,!0,!1)+">"),function(){var e=d.items;if("number"==typeof e.length)for(var n=0,a=e.length;n<a;n++){var s=e[n];i.push("<option"+jade.attr("value",""+s.id,!0,!1)+jade.attr("selected",s.selected,!0,!1)+">"+jade.escape(null==(t=s.name)?"":t)+"</option>")}else{var a=0;for(var n in e){a++;var s=e[n];i.push("<option"+jade.attr("value",""+s.id,!0,!1)+jade.attr("selected",s.selected,!0,!1)+">"+jade.escape(null==(t=s.name)?"":t)+"</option>")}}}.call(this),i.push("</optgroup>")):i.push("<option"+jade.attr("value",""+d.id,!0,!1)+jade.attr("selected",d.selected,!0,!1)+">"+jade.escape(null==(t=d.name)?"":t)+"</option>")}else{var s=0;for(var a in e){s++;var d=e[a];null!=d.group?(i.push("<optgroup"+jade.attr("label",""+d.group,!0,!1)+">"),function(){var e=d.items;if("number"==typeof e.length)for(var n=0,a=e.length;n<a;n++){var s=e[n];i.push("<option"+jade.attr("value",""+s.id,!0,!1)+jade.attr("selected",s.selected,!0,!1)+">"+jade.escape(null==(t=s.name)?"":t)+"</option>")}else{var a=0;for(var n in e){a++;var s=e[n];i.push("<option"+jade.attr("value",""+s.id,!0,!1)+jade.attr("selected",s.selected,!0,!1)+">"+jade.escape(null==(t=s.name)?"":t)+"</option>")}}}.call(this),i.push("</optgroup>")):i.push("<option"+jade.attr("value",""+d.id,!0,!1)+jade.attr("selected",d.selected,!0,!1)+">"+jade.escape(null==(t=d.name)?"":t)+"</option>")}}}.call(this),i.push("</select>")}.call(this,"classes"in n?n.classes:"undefined"!=typeof classes?classes:void 0,"items"in n?n.items:"undefined"!=typeof items?items:void 0,"undefined"in n?n.undefined:void 0),i.join("")}},{}]},{},[1]);