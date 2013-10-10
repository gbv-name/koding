class DashboardAppController extends AppController

  KD.registerAppClass this,
    name         : "Dashboard"
    route        : "/:name?/Dashboard"
    hiddenHandle : yes
    navItem      :
      title      : "Group"
      path       : "/Dashboard"
      order      : 75
      role       : "admin"
      type       : "account"

  constructor: (options = {}, data) ->

    options.view = new DashboardAppView
      testPath   : "groups-dashboard"

    data or= (KD.getSingleton "groupsController").getCurrentGroup()

    super options, data

    @tabData = [
      #   name        : 'Readme'
      #   viewOptions :
      #     viewClass : GroupReadmeView
      #     lazy      : no
      # ,
        name         : 'Settings'
        viewOptions  :
          viewClass  : GroupGeneralSettingsView
          lazy       : yes
      ,
        name         : 'Members'
        viewOptions  :
          viewClass  : GroupsMemberPermissionsView
          lazy       : yes
          callback   : @bound 'membersViewAdded'
      ,
        name         : 'Invitations'
        viewOptions  :
          viewClass  : GroupsInvitationView
          lazy       : yes
      ,
        name         : 'Permissions'
        viewOptions  :
          viewClass  : GroupPermissionsView
          lazy       : yes
      ,
        name         : 'Membership policy'
        hiddenHandle : @getData().privacy is 'public'
        viewOptions  :
          viewClass  : GroupsMembershipPolicyDetailView
          lazy       : yes
          callback   : @bound 'policyViewAdded'
      ,
        name         : 'Payment'
        viewOptions  :
          viewClass  : GroupPaymentSettingsView
          lazy       : yes
          callback   : @bound 'paymentViewAdded'
      ,
        name         : 'Products'
        viewOptions  :
          viewClass  : GroupProductSettingsView
          lazy       : yes
          callback   : @bound 'productViewAdded'
      ,
        name         : 'Blocked Users'
        hiddenHandle : @getData().privacy is 'public'
        kodingOnly   : yes # this is only intended for koding group, we assume koding group is super-group
        viewOptions  :
          viewClass  : GroupsBlockedUserView
          lazy       : yes
      # CURRENTLY DISABLED

      # ,
      #   name        : 'Vocabulary'
      #   viewOptions :
      #     viewClass : GroupsVocabulariesView
      #     lazy      : yes
      #     callback  : @vocabularyViewAdded
      # ,
      #   name        : 'Bundle'
      #   viewOptions :
      #     viewClass : GroupsBundleView
      #     lazy      : yes
      #     callback  : @bundleViewAdded
    ]

  fetchTabData: (callback) -> @utils.defer => callback @tabData

  membersViewAdded: (pane, view) ->
    group = view.getData()
    # pane.on 'PaneDidShow', ->
    #   view.refresh()  if pane.tabHandle.isDirty
    #   pane.tabHandle.markDirty no
    group.on 'MemberAdded', ->
      log 'MemberAdded'
      # {tabHandle} = pane
      # tabHandle.markDirty()

  policyViewAdded: (pane, view) ->

  paymentViewAdded: (pane, view) ->
    paymentController = KD.getSingleton 'paymentController'

    group = @getData()

    group.fetchPaymentMethod (err, paymentMethod) ->
      console.log { err, paymentMethod }
    # paymentController.fetchBillingInfo 'group', (err, billingInfo) =>
      view.setBillingInfo paymentMethod

    @paymentView = view

    { loader }  = view.settingsForm.inputs.billing

    view.on 'BillingEditRequested', =>
      loader.show()
      @showBillingInfoModal ->
        loader.hide()

  productViewAdded: (pane, view) ->


  showBillingInfoModal: (callback) ->
    modal = @createBillingInfoModal()

    modal.on 'PaymentInfoSubmitted', (formData) =>
      @getData().setBillingInfo formData, (err) =>
        console.error err  if err

        @paymentView?.setBillingInfo formData

        modal.destroy()

    modal.on 'CountryDataPopulated', -> callback null, modal

  createBillingInfoModal: ->

    paymentController = KD.getSingleton "paymentController"

    billingInfoModal = paymentController.createBillingInfoModal 'group', {}

    paymentController.fetchBillingInfo 'group', (err, groupBillingInfo) ->

      if groupBillingInfo
        billingInfoModal.setBillingInfo groupBillingInfo

      else
        paymentController.fetchBillingInfo 'user', (err, personalBillingInfo) ->

          if personalBillingInfo
            { billing } = personalBillingInfo

            useExistingModal = new KDModalView
              title: 'Would you like to link an existing payment method?'
              buttons         :
                "Use another payment method":
                  style       : 'modal-cancel'
                  callback    : -> useExistingModal.destroy()

            billingMethodView = new BillingMethodView {}, billing
            useExistingModal.addSubView billingMethodView

            billingMethodView.on 'BillingEditRequested', ->
              billingInfoModal.setBillingInfo personalBillingInfo.billing
              useExistingModal.destroy()


    return billingInfoModal

  # vocabularyViewAdded:(pane, view)->
  #   group = view.getData()
  #   group.fetchVocabulary (err, vocab)-> view.setVocabulary vocab
  #   view.on 'VocabularyCreateRequested', ->
  #     {JVocabulary} = KD.remote.api
  #     JVocabulary.create {}, (err, vocab)-> view.setVocabulary vocab

  # bundleViewAdded:(pane, view)-> console.log 'bundle view', view
