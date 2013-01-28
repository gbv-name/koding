fs = require 'fs'
nodePath = require 'path'

deepFreeze = require 'koding-deep-freeze'

version = "0.9.9a" #fs.readFileSync nodePath.join(__dirname, '../.revision'), 'utf-8'

# PROD
mongo = 'PROD-koding:34W4BXx595ib3J72k5Mh@localhost:27017/beta_koding?auto_reconnect'

projectRoot = nodePath.join __dirname, '..'

# rabbitPrefix = (
#   try fs.readFileSync nodePath.join(projectRoot, '.rabbitvhost'), 'utf8'
#   catch e then ""
# ).trim()

socialQueueName = "koding-social-prod"

module.exports = deepFreeze
  uri           :
    address     : "https://koding.com"
  projectRoot   : projectRoot
  version       : version
  webserver     :
    login       : 'prod-webserver'
    port        : 3020
    clusterSize : 10
    queueName   : socialQueueName+'web'
    watch       : no
  mongo         : mongo
  runGoBroker   : yes
  compileGo     : yes
  buildClient   : yes
  misc          :
    claimGlobalNamesForUsers: no
    updateAllSlugs : no
    debugConnectionErrors: yes
  uploads       :
    enableStreamingUploads: no
    distribution: 'https://d2mehr5c6bceom.cloudfront.net'
    s3          :
      awsAccountId        : '616271189586'
      awsAccessKeyId      : 'AKIAJO74E23N33AFRGAQ'
      awsSecretAccessKey  : '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'
      bucket              : 'koding-uploads'
  # loadBalancer  :
  #   port        : 3000
  #   heartbeat   : 5000
    # httpRedirect:
    #   port      : 80 # don't forget port 80 requires sudo
  bitly :
    username  : "kodingen"
    apiKey    : "R_677549f555489f455f7ff77496446ffa"
  goConfig:
    HomePrefix:   "/Users/"
    UseLVE:       true
  authWorker    :
    login       : 'prod-authworker'
    queueName   : socialQueueName+'auth'
    authResourceName: 'auth'
    numberOfWorkers: 1
    watch       : no
  social        :
    login       : 'prod-social'
    numberOfWorkers: 10
    watch       : no
    queueName   : socialQueueName
  feeder        :
    queueName   : "koding-feeder"
    exchangePrefix: "followable-"
    numberOfWorkers: 2
  presence      :
    exchange    : 'services-presence'
  client        :
    pistachios  : yes
    version     : version
    minify      : yes
    watch       : no
    js          : "./website/js/kd.#{version}.js"
    css         : "./website/css/kd.#{version}.css"
    indexMaster: "./client/index-master.html"
    index       : "./website/index.html"
    includesFile: '../CakefileIncludes.coffee'
    useStaticFileServer: no
    staticFilesBaseUrl: 'https://koding.com'
    runtimeOptions:
      resourceName: socialQueueName
      suppressLogs: yes
      version   : version
      mainUri   : 'https://koding.com'
      broker    :
        sockJS  : 'https://mq.koding.com/subscribe'
      apiUri    : 'https://api.koding.com'
      # Is this correct?
      appsUri   : 'https://app.koding.com'
  mq            :
    host        : 'localhost'
    login       : 'PROD-k5it50s4676pO9O'
    componentUser: "prod-<component>"
    password    : 'Dtxym6fRJXx4GJz'
    heartbeat   : 10
    vhost       : '/'
  kites:
    disconnectTimeout: 3e3
    vhost       : '/'
  email         :
    host        : 'koding.com'
    protocol    : 'https:'
    defaultFromAddress: 'hello@koding.com'
    notificationCron  : '*/10 * * * * *'
  guests        :
    # define this to limit the number of guset accounts
    # to be cleaned up per collection cycle.
    poolSize        : 1e4
    batchSize       : undefined
    cleanupCron     : '*/10 * * * * *'
  logger            :
    mq              :
      host          : 'localhost'
      login         : 'PROD-k5it50s4676pO9O'
      password      : 'Dtxym6fRJXx4GJz'
  pidFile       : '/tmp/koding.server.pid'
  loggr:
    push: yes
    url: "http://post.loggr.net/1/logs/koding/events"
    apiKey: "eb65f620b72044118015d33b4177f805"
  librato:
    push: yes
    email: "devrim@koding.com"
    token: "3f79eeb972c201a6a8d3461d4dc5395d3a1423f4b7a2764ec140572e70a7bce0"
    interval: 30000

