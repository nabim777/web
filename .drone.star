# UI Test suite types
FULL = 1
FEDERATED = 2
NOTIFICATIONS = 3

ALPINE_GIT = "alpine/git:latest"
APACHE_TIKA = "apache/tika:2.8.0.0"
MINIO_MC = "minio/mc:RELEASE.2021-10-07T04-19-58Z"
OC_CI_ALPINE = "owncloudci/alpine:latest"
OC_CI_BAZEL_BUILDIFIER = "owncloudci/bazel-buildifier"
OC_CI_CORE_NODEJS = "owncloudci/core:nodejs14"
OC_CI_DRONE_ANSIBLE = "owncloudci/drone-ansible:latest"
OC_CI_DRONE_SKIP_PIPELINE = "owncloudci/drone-skip-pipeline"
OC_CI_GOLANG = "owncloudci/golang:1.19"
OC_CI_HUGO = "owncloudci/hugo:0.115.2"
OC_CI_NODEJS = "owncloudci/nodejs:18"
OC_CI_PHP = "owncloudci/php:7.4"
OC_CI_WAIT_FOR = "owncloudci/wait-for:latest"
OC_TESTING_MIDDLEWARE = "owncloud/owncloud-test-middleware:1.8.3"
OC_UBUNTU = "owncloud/ubuntu:20.04"
PLUGINS_DOCKER = "plugins/docker:20.14"
PLUGINS_GH_PAGES = "plugins/gh-pages:1"
PLUGINS_GIT_ACTION = "plugins/git-action:1"
PLUGINS_GITHUB_RELEASE = "plugins/github-release:1"
PLUGINS_S3 = "plugins/s3"
PLUGINS_S3_CACHE = "plugins/s3-cache:1"
PLUGINS_SLACK = "plugins/slack:1"
SELENIUM_STANDALONE_CHROME = "selenium/standalone-chrome:104.0-20220812"
SELENIUM_STANDALONE_FIREFOX = "selenium/standalone-firefox:104.0-20220812"
SONARSOURCE_SONAR_SCANNER_CLI = "sonarsource/sonar-scanner-cli:5.0"
TOOLHIPPIE_CALENS = "toolhippie/calens:latest"

WEB_PUBLISH_NPM_PACKAGES = ["babel-preset", "eslint-config", "extension-sdk", "prettier-config", "tsconfig", "web-client", "web-pkg"]
WEB_PUBLISH_NPM_ORGANIZATION = "@ownclouders"

dir = {
    "base": "/var/www/owncloud",
    "federated": "/var/www/owncloud/federated",
    "server": "/var/www/owncloud/server",
    "web": "/var/www/owncloud/web",
    "ocis": "/var/www/owncloud/ocis-build",
    "commentsFile": "/var/www/owncloud/web/comments.file",
    "app": "/srv/app",
    "config": "/srv/config",
    "ocisConfig": "/srv/config/drone/config-ocis.json",
    "ocisIdentifierRegistrationConfig": "/srv/config/drone/identifier-registration.yml",
    "ocisRevaDataRoot": "/srv/app/tmp/ocis/owncloud/data/",
    "testingDataDir": "/srv/app/testing/data/",
}

config = {
    "app": "web",
    "rocketchat": {
        "channel": "builds",
        "from_secret": "rocketchat_chat_webhook",
    },
    "branches": [
        "master",
    ],
    "pnpmlint": True,
    "e2e": {
        "oCIS-1": {
            "earlyFail": True,
            "skip": False,
            "tikaNeeded": True,
            "featurePaths": [
                "tests/e2e/cucumber/features/{smoke,journeys}/*.feature",
            ],
        },
        "oCIS-2": {
            "earlyFail": True,
            "skip": False,
            "featurePaths": [
                "tests/e2e/cucumber/features/smoke/{spaces,admin-settings}/*.feature",
            ],
        },
        "oCIS-app-provider": {
            "skip": False,
            "featurePaths": [
                "tests/e2e/cucumber/features/smoke/app-provider/*.feature",
            ],
        },
    },
    "acceptance": {
        "webUI": {
            "type": FULL,
            "servers": [
                "",
            ],
            "suites": {
                "oCISBasic": [
                    "webUIPrivateLinks",
                    "webUIPreview",
                    "webUIAccount",
                    "webUILogin",
                ],
                "webUIWebdavLockProtection": "oCISWebdavLockProtection",
                "oCISSharingBasic": [
                    "webUISharingAcceptShares",
                    "webUIRestrictSharing",
                ],
                "webUIFavorites": "oCISFavorites",
                "oCISFiles1": [
                    "webUICreateFilesFolders",
                    "webUIDeleteFilesFolders",
                ],
                "oCISFiles2": [
                    "webUIFilesList",
                    "webUIFilesDetails",
                    "webUIFilesSearch",
                ],
                "oCISFiles3": [
                    "webUIRenameFiles",
                ],
                "oCISFiles4": [
                    "webUIFiles",
                    "webUIRenameFolders",
                ],
                "oCISFiles5": [
                    "webUIFilesCopy",
                    "webUIFilesActionMenu",
                    "webUITextEditor",
                ],
                "oCISSharingInternal1": [
                    "webUISharingInternalGroups",
                    "webUISharingInternalGroupsEdgeCases",
                ],
                "oCISSharingInternal2": [
                    "webUISharingInternalUsers",
                    "webUISharingInternalUsersBlacklisted",
                    "webUISharingInternalUsersCollaborator",
                    "webUISharingExpirationDate",
                ],
                "oCISSharingInternal3": [
                    "webUISharingInternalGroupsSharingIndicator",
                    "webUISharingInternalUsersSharingIndicator",
                    "webUISharingInternalUsersShareWithPage",
                    "webUIOperationsWithFolderShares",
                ],
                "oCISSharingAutocompletionResharing": [
                    "webUISharingAutocompletion",
                    "webUIResharing1",
                    "webUIResharing2",
                ],
                "oCISSharingPerm1": [
                    "webUISharingPermissionsUsers",
                    "webUISharingFolderPermissionsGroups",
                ],
                "oCISSharingPerm2": [
                    "webUISharingFilePermissionsGroups",
                    "webUISharingFilePermissionMultipleUsers",
                    "webUISharingFolderPermissionMultipleUsers",
                    "webUISharingFolderAdvancedPermissionMultipleUsers",
                    "webUISharingFolderAdvancedPermissionsGroups",
                ],
                "oCISSharingPublic1": [
                    "webUISharingPublicBasic",
                ],
                "oCISSharingPublic2": [
                    "webUISharingPublicExpire",
                    "webUISharingPublicManagement",
                ],
                "oCISSharingPublic3": [
                    "webUISharingPublicDifferentRoles",
                ],
                "oCISUploadMove": [
                    "webUIUpload",
                    "webUIMoveFilesFolders",
                ],
                "oCISTrashbinJourney": [
                    "webUITrashbinDelete",
                    "webUITrashbinFilesFolders",
                    "webUITrashbinRestore",
                    "webUIUserJourney",
                ],
            },
            "extraEnvironment": {
                "NODE_TLS_REJECT_UNAUTHORIZED": "0",
                "SERVER_HOST": "https://ocis:9200",
                "BACKEND_HOST": "https://ocis:9200",
                "RUN_ON_OCIS": "true",
                "TESTING_DATA_DIR": "%s" % dir["testingDataDir"],
                "OCIS_REVA_DATA_ROOT": "%s" % dir["ocisRevaDataRoot"],
                "WEB_UI_CONFIG_FILE": "%s" % dir["ocisConfig"],
                "EXPECTED_FAILURES_FILE": "%s/tests/acceptance/expected-failures-with-ocis-server-ocis-storage.md" % dir["web"],
            },
            "filterTags": "not @skip and not @skipOnOCIS and not @notToImplementOnOCIS",
            "screenShots": True,
        },
    },
    "build": True,
}

# UI Test Suites
# These list contains all the test suites that are present
# When adding new test suites, make sure to update these lists
rootSharingTestSuites = [
    "webUIResharingToRoot",
    "webUISharingAcceptSharesToRoot",
    "webUISharingInternalGroupsToRoot",
    "webUISharingInternalGroupsToRootEdgeCases",
    "webUISharingInternalGroupsToRootSharingIndicator",
    "webUISharingInternalUsersToRoot",
    "webUISharingInternalUsersToRootBlacklisted",
    "webUISharingInternalUsersToRootCollaborator",
    "webUISharingInternalUsersToRootPreviews",
    "webUISharingInternalUsersToRootShareWithPage",
    "webUISharingInternalUsersToRootSharingIndicator",
    "webUISharingPermissionToRoot",
]

basicTestSuites = [
    "webUIAccount",
    "webUICreateFilesFolders",
    "webUIDeleteFilesFolders",
    "webUIFavorites",
    "webUIFiles",
    "webUIFilesActionMenu",
    "webUIFilesCopy",
    "webUIFilesDetails",
    "webUIFilesList",
    "webUIFilesSearch",
    "webUILogin",
    "webUIMoveFilesFolders",
    "webUIOperationsWithFolderShares",
    "webUIPreview",
    "webUIPrivateLinks",
    "webUIRenameFiles",
    "webUIRenameFolders",
    "webUIResharing1",
    "webUIResharing2",
    "webUIRestrictSharing",
    "webUISharingAcceptShares",
    "webUISharingAutocompletion",
    "webUISharingExpirationDate",
    "webUISharingFilePermissionMultipleUsers",
    "webUISharingFilePermissionsGroups",
    "webUISharingFolderAdvancedPermissionMultipleUsers",
    "webUISharingFolderAdvancedPermissionsGroups",
    "webUISharingFolderPermissionMultipleUsers",
    "webUISharingFolderPermissionsGroups",
    "webUISharingInternalGroups",
    "webUISharingInternalGroupsEdgeCases",
    "webUISharingInternalGroupsSharingIndicator",
    "webUISharingInternalUsers",
    "webUISharingInternalUsersBlacklisted",
    "webUISharingInternalUsersCollaborator",
    "webUISharingInternalUsersShareWithPage",
    "webUISharingInternalUsersSharingIndicator",
    "webUISharingPermissionsUsers",
    "webUISharingPublicBasic",
    "webUISharingPublicDifferentRoles",
    "webUISharingPublicExpire",
    "webUISharingPublicManagement",
    "webUITextEditor",
    "webUITrashbinDelete",
    "webUITrashbinFilesFolders",
    "webUITrashbinRestore",
    "webUIUpload",
    "webUIWebdavLockProtection",
]

ocisSpecificTestSuites = [
    "webUIUserJourney",
]

# minio mc environment variables
minio_mc_environment = {
    "CACHE_BUCKET": {
        "from_secret": "cache_s3_bucket",
    },
    "MC_HOST": {
        "from_secret": "cache_s3_server",
    },
    "AWS_ACCESS_KEY_ID": {
        "from_secret": "cache_s3_access_key",
    },
    "AWS_SECRET_ACCESS_KEY": {
        "from_secret": "cache_s3_secret_key",
    },
}

go_step_volumes = [{
    "name": "server",
    "path": dir["app"],
}, {
    "name": "gopath",
    "path": "/go",
}, {
    "name": "configs",
    "path": dir["config"],
}]

web_workspace = {
    "base": dir["base"],
    "path": config["app"],
}

def checkTestSuites():
    for testGroupName, test in config["acceptance"].items():
        suites = []
        for key, items in test["suites"].items():
            if (type(items) == "list"):
                suites += items
            elif (type(items) == "string"):
                suites.append(key)
            else:
                print("Error: invalid value for suite, it must be a list or string")
                return False

        expected = []
        if (test["type"] == FULL):
            expected += basicTestSuites

        expected += ocisSpecificTestSuites

        if (sorted(suites) != sorted(expected)):
            print("Error: Suites dont match " + testGroupName)
            print(Diff(sorted(suites), sorted(expected)))

    return True

def Diff(li1, li2):
    li_dif = [i for i in li1 + li2 if i not in li1 or i not in li2]
    return li_dif

def main(ctx):
    uiSuitesCheck = checkTestSuites()
    if (uiSuitesCheck == False):
        print("Errors detected. Review messages above.")
        return []

    before = beforePipelines(ctx)

    stages = pipelinesDependsOn(stagePipelines(ctx), before)

    if (stages == False):
        print("Errors detected. Review messages above.")
        return []

    after = pipelinesDependsOn(afterPipelines(ctx), stages)

    pipelines = before + stages + after

    deploys = example_deploys(ctx)
    if ctx.build.event != "cron":
        # run example deploys on cron even if some prior pipelines fail
        deploys = pipelinesDependsOn(deploys, pipelines)

    pipelines = pipelines + deploys + pipelinesDependsOn(
        [
            purgeBuildArtifactCache(ctx),
        ],
        pipelines,
    )

    pipelineSanityChecks(ctx, pipelines)
    return pipelines

def beforePipelines(ctx):
    return checkStarlark() + \
           licenseCheck(ctx) + \
           documentation(ctx) + \
           changelog(ctx) + \
           pnpmCache(ctx) + \
           cacheOcisPipeline(ctx) + \
           pipelinesDependsOn(buildCacheWeb(ctx), pnpmCache(ctx)) + \
           pipelinesDependsOn(pnpmlint(ctx), pnpmCache(ctx))

def stagePipelines(ctx):
    unit_test_pipelines = unitTests(ctx)
    e2e_pipelines = e2eTests(ctx)
    acceptance_pipelines = acceptance(ctx)
    return unit_test_pipelines + pipelinesDependsOn(e2e_pipelines + acceptance_pipelines, unit_test_pipelines)

def afterPipelines(ctx):
    return build(ctx) + pipelinesDependsOn(notify(), build(ctx))

def pnpmCache(ctx):
    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "cache-pnpm",
        "workspace": {
            "base": dir["base"],
            "path": config["app"],
        },
        "steps": skipIfUnchanged(ctx, "cache") +
                 installPnpm() +
                 rebuildBuildArtifactCache(ctx, "pnpm", ".pnpm-store") +
                 rebuildBuildArtifactCache(ctx, "playwright", ".playwright"),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }]

def pnpmlint(ctx):
    pipelines = []

    if "pnpmlint" not in config:
        return pipelines

    if type(config["pnpmlint"]) == "bool":
        if not config["pnpmlint"]:
            return pipelines

    result = {
        "kind": "pipeline",
        "type": "docker",
        "name": "lint",
        "workspace": {
            "base": dir["base"],
            "path": config["app"],
        },
        "steps": skipIfUnchanged(ctx, "lint") +
                 restoreBuildArtifactCache(ctx, "pnpm", ".pnpm-store") +
                 installPnpm() +
                 lint(),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }

    for branch in config["branches"]:
        result["trigger"]["ref"].append("refs/heads/%s" % branch)

    pipelines.append(result)

    return pipelines

def build(ctx):
    pipelines = []

    if "build" not in config:
        return pipelines

    if type(config["build"]) == "bool":
        if not config["build"]:
            return pipelines

    steps = restoreBuildArtifactCache(ctx, "pnpm", ".pnpm-store") + installPnpm() + buildRelease(ctx)

    if determineReleasePackage(ctx) == None:
        steps += buildDockerImage()

    result = {
        "kind": "pipeline",
        "type": "docker",
        "name": "build",
        "workspace": {
            "base": dir["base"],
            "path": config["app"],
        },
        "steps": steps,
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
            ],
        },
    }

    pipelines.append(result)

    return pipelines

def changelog(ctx):
    pipelines = []
    repo_slug = ctx.build.source_repo if ctx.build.source_repo else ctx.repo.slug

    result = {
        "kind": "pipeline",
        "type": "docker",
        "name": "changelog",
        "clone": {
            "disable": True,
        },
        "steps": [
            {
                "name": "clone",
                "image": PLUGINS_GIT_ACTION,
                "settings": {
                    "actions": [
                        "clone",
                    ],
                    "remote": "https://github.com/%s" % (repo_slug),
                    "branch": ctx.build.source if ctx.build.event == "pull_request" else "master",
                    "path": "/drone/src",
                    "netrc_machine": "github.com",
                    "netrc_username": {
                        "from_secret": "github_username",
                    },
                    "netrc_password": {
                        "from_secret": "github_token",
                    },
                },
            },
            {
                "name": "generate",
                "image": TOOLHIPPIE_CALENS,
                "commands": [
                    "calens >| CHANGELOG.md",
                ],
            },
            {
                "name": "diff",
                "image": OC_CI_ALPINE,
                "commands": [
                    "git diff",
                ],
            },
            {
                "name": "output",
                "image": TOOLHIPPIE_CALENS,
                "commands": [
                    "cat CHANGELOG.md",
                ],
            },
            {
                "name": "publish",
                "image": PLUGINS_GIT_ACTION,
                "settings": {
                    "actions": [
                        "commit",
                        "push",
                    ],
                    "message": "Automated changelog update [skip ci]",
                    "branch": "master",
                    "author_email": "devops@owncloud.com",
                    "author_name": "ownClouders",
                    "netrc_machine": "github.com",
                    "netrc_username": {
                        "from_secret": "github_username",
                    },
                    "netrc_password": {
                        "from_secret": "github_token",
                    },
                },
                "when": {
                    "ref": {
                        "exclude": [
                            "refs/pull/**",
                            "refs/tags/**",
                        ],
                    },
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/pull/**",
            ],
        },
    }

    pipelines.append(result)

    return pipelines

def buildCacheWeb(ctx):
    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "cache-web",
        "workspace": {
            "base": dir["base"],
            "path": config["app"],
        },
        "steps": skipIfUnchanged(ctx, "cache") +
                 restoreBuildArtifactCache(ctx, "pnpm", ".pnpm-store") +
                 [{
                     "name": "build-web",
                     "image": OC_CI_NODEJS,
                     "commands": [
                         "pnpm config set store-dir ./.pnpm-store",
                         "make dist",
                     ],
                 }] +
                 rebuildBuildArtifactCache(ctx, "web-dist", "dist"),
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }]

def unitTests(ctx):
    sonar_env = {
        "SONAR_TOKEN": {
            "from_secret": "sonar_token",
        },
    }
    if ctx.build.event == "pull_request":
        sonar_env.update({
            "SONAR_PULL_REQUEST_BASE": "%s" % (ctx.build.target),
            "SONAR_PULL_REQUEST_BRANCH": "%s" % (ctx.build.source),
            "SONAR_PULL_REQUEST_KEY": "%s" % (ctx.build.ref.replace("refs/pull/", "").split("/")[0]),
        })

    repo_slug = ctx.build.source_repo if ctx.build.source_repo else ctx.repo.slug

    fork_handling = []
    if ctx.build.source_repo != "" and ctx.build.source_repo != ctx.repo.slug:
        fork_handling = [
            "git remote add fork https://github.com/%s.git" % (ctx.build.source_repo),
            "git fetch fork",
        ]

    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "unit-tests",
        "workspace": {
            "base": dir["base"],
            "path": config["app"],
        },
        "clone": {
            "disable": True,  # Sonarcloud does not apply issues on already merged branch
        },
        "steps": [
                     {
                         "name": "clone",
                         "image": ALPINE_GIT,
                         "commands": [
                                         # Always use the owncloud/web repository as base to have an up to date default branch.
                                         # This is needed for the skipIfUnchanged step, since it references a commit on master (which could be absent on a fork)
                                         "git clone https://github.com/%s.git ." % (ctx.repo.slug),
                                     ] + fork_handling +
                                     [
                                         "git checkout $DRONE_COMMIT",
                                     ],
                     },
                 ] +
                 skipIfUnchanged(ctx, "unit-tests") +
                 restoreBuildArtifactCache(ctx, "pnpm", ".pnpm-store") +
                 installPnpm() +
                 [
                     {
                         "name": "unit-tests",
                         "image": OC_CI_NODEJS,
                         "commands": [
                             "pnpm build:tokens",
                             "pnpm test:unit --coverage",
                         ],
                     },
                     {
                         "name": "sonarcloud",
                         "image": SONARSOURCE_SONAR_SCANNER_CLI,
                         "environment": sonar_env,
                     },
                 ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }]

def e2eTests(ctx):
    e2e_workspace = {
        "base": dir["base"],
        "path": config["app"],
    }

    e2e_volumes = [{
        "name": "uploads",
        "temp": {},
    }, {
        "name": "configs",
        "temp": {},
    }, {
        "name": "gopath",
        "temp": {},
    }, {
        "name": "ocis-config",
        "temp": {},
    }]

    default = {
        "skip": False,
        "logLevel": "2",
        "reportTracing": "false",
        "db": "mysql:5.5",
        "featurePaths": "",
        "tikaNeeded": False,
    }

    e2e_trigger = {
        "ref": [
            "refs/heads/master",
            "refs/heads/stable-*",
            "refs/tags/**",
            "refs/pull/**",
        ],
    }

    pipelines = []
    params = {}
    matrices = config["e2e"]

    for suite, matrix in matrices.items():
        for item in default:
            params[item] = matrix[item] if item in matrix else default[item]

        if suite == "oCIS-app-provider" and not "full-ci" in ctx.build.title.lower() and ctx.build.event != "cron":
            continue

        if params["skip"]:
            continue

        if ("with-tracing" in ctx.build.title.lower()):
            params["reportTracing"] = "true"

        environment = {
            "HEADLESS": "true",
            "RETRY": "1",
            "REPORT_TRACING": params["reportTracing"],
        }

        services = []
        depends_on = []
        steps = skipIfUnchanged(ctx, "e2e-tests") + \
                restoreBuildArtifactCache(ctx, "pnpm", ".pnpm-store") + \
                restoreBuildArtifactCache(ctx, "playwright", ".playwright") + \
                installPnpm() + \
                restoreBuildArtifactCache(ctx, "web-dist", "dist") + \
                setupServerConfigureWeb(params["logLevel"]) + \
                restoreOcisCache()

        # oCIS specific environment variables
        environment["BASE_URL_OCIS"] = "ocis:9200"
        environment["OCIS"] = "true"
        environment["API_TOKEN"] = "true"

        # oCIS specific dependencies
        depends_on = ["cache-ocis"]

        if suite == "oCIS-app-provider":
            # app-provider specific steps
            steps += wopiServer() + \
                     collaboraService() + \
                     onlyofficeService() + \
                     ocisService("app-provider") + \
                     appProviderService("collabora") + \
                     appProviderService("onlyoffice")
        else:
            # oCIS specific steps
            steps += copyFilesForUpload() + \
                     (tikaService() if params["tikaNeeded"] else []) + \
                     ocisService("e2e-tests", tika_enabled = params["tikaNeeded"]) + \
                     getSkeletonFiles()

        steps += [{
                     "name": "e2e-tests",
                     "image": OC_CI_NODEJS,
                     "environment": environment,
                     "commands": [
                         "pnpm test:e2e:cucumber %s" % " ".join(params["featurePaths"]),
                     ],
                 }] + \
                 uploadTracingResult(ctx) + \
                 logTracingResult(ctx, "e2e-tests %s" % suite)

        pipelines.append({
            "kind": "pipeline",
            "type": "docker",
            "name": "e2e-tests-%s" % suite,
            "workspace": e2e_workspace,
            "steps": steps,
            "services": services,
            "depends_on": depends_on,
            "trigger": e2e_trigger,
            "volumes": e2e_volumes,
        })
    return pipelines

def acceptance(ctx):
    pipelines = []

    if "acceptance" not in config:
        return pipelines

    if type(config["acceptance"]) == "bool":
        if not config["acceptance"]:
            return pipelines

    errorFound = False

    default = {
        "servers": [],
        "browsers": ["chrome"],
        "databases": ["mysql:5.5"],
        "extraEnvironment": {},
        "cronOnly": False,
        "filterTags": "not @skip and not @skipOnOCIS and not @notToImplementOnOCIS",
        "logLevel": "2",
        "notificationsAppNeeded": False,
        "screenShots": False,
        "openIdConnect": False,
        "skip": False,
        "debugSuites": [],
        "retry": True,
    }

    if "defaults" in config:
        if "acceptance" in config["defaults"]:
            for item in config["defaults"]["acceptance"]:
                default[item] = config["defaults"]["acceptance"][item]

    for category, matrix in config["acceptance"].items():
        if type(matrix["suites"]) == "list":
            suites = {}
            for suite in matrix["suites"]:
                suites[suite] = suite
        else:
            suites = matrix["suites"]

        if "debugSuites" in matrix and len(matrix["debugSuites"]) != 0:
            if type(matrix["debugSuites"]) == "list":
                suites = {}
                for suite in matrix["debugSuites"]:
                    suites[suite] = suite
            else:
                suites = matrix["debugSuites"]

        for key, value in suites.items():
            if type(value) == "list":
                suite = value
                suiteName = key
                alternateSuiteName = key
            else:
                suite = key
                alternateSuiteName = value
                suiteName = value

            params = {}
            for item in default:
                params[item] = matrix[item] if item in matrix else default[item]

            for server in params["servers"]:
                for browser in params["browsers"]:
                    for db in params["databases"]:
                        if params["skip"]:
                            continue

                        browserString = "" if browser == "" else "-" + browser
                        serverString = "" if server == "" else "-" + server.replace("daily-", "").replace("-qa", "")
                        name = "%s%s%s" % (suiteName, browserString, serverString)
                        maxLength = 50
                        nameLength = len(name)
                        if nameLength > maxLength:
                            print("Error: generated stage name of length", nameLength, "is not supported. The maximum length is " + str(maxLength) + ".", name)
                            errorFound = True

                        steps = []

                        # TODO: don't start services if we skip it -> maybe we need to convert them to steps
                        steps += skipIfUnchanged(ctx, "acceptance-tests")
                        steps += restoreBuildArtifactCache(ctx, "web-dist", "dist")
                        steps += setupServerConfigureWeb(params["logLevel"])

                        services = browserService(alternateSuiteName, browser) + middlewareService()

                        # Services and steps required for running tests with oCIS
                        steps += restoreOcisCache() + ocisService("acceptance-tests") + getSkeletonFiles()

                        # Wait for test-related services to be up
                        steps += waitForBrowserService()
                        steps += waitForMiddlewareService()

                        # run the acceptance tests
                        steps += runWebuiAcceptanceTests(ctx, suite, alternateSuiteName, params["filterTags"], params["extraEnvironment"], params["screenShots"], params["retry"])

                        # Capture the screenshots from acceptance tests (only runs on failure)
                        if (params["screenShots"]):
                            steps += uploadScreenshots() + logAcceptanceTestsScreenshotsResult(suiteName)

                        result = {
                            "kind": "pipeline",
                            "type": "docker",
                            "name": name,
                            "workspace": {
                                "base": dir["base"],
                                "path": config["app"],
                            },
                            "steps": steps,
                            "services": services,
                            "trigger": {
                                "ref": [
                                    "refs/tags/**",
                                    "refs/pull/**",
                                ],
                            },
                            "volumes": [{
                                "name": "uploads",
                                "temp": {},
                            }, {
                                "name": "configs",
                                "temp": {},
                            }, {
                                "name": "gopath",
                                "temp": {},
                            }],
                        }

                        result = pipelineDependsOn(result, cacheOcisPipeline(ctx))

                        for branch in config["branches"]:
                            result["trigger"]["ref"].append("refs/heads/%s" % branch)

                        if (params["cronOnly"]):
                            result["trigger"]["event"] = ["cron"]

                        pipelines.append(result)

    if errorFound:
        return False

    return pipelines

def notify():
    pipelines = []

    result = {
        "kind": "pipeline",
        "type": "docker",
        "name": "chat-notifications",
        "clone": {
            "disable": True,
        },
        "steps": [
            {
                "name": "notify-rocketchat",
                "image": PLUGINS_SLACK,
                "settings": {
                    "webhook": {
                        "from_secret": config["rocketchat"]["from_secret"],
                    },
                    "channel": config["rocketchat"]["channel"],
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/tags/**",
            ],
            "status": [
                "success",
                "failure",
            ],
        },
    }

    for branch in config["branches"]:
        result["trigger"]["ref"].append("refs/heads/%s" % branch)

    pipelines.append(result)

    return pipelines

def browserService(alternateSuiteName, browser):
    if browser == "chrome":
        return [{
            "name": "selenium",
            "image": SELENIUM_STANDALONE_CHROME,
            "volumes": [{
                "name": "uploads",
                "path": "/uploads",
            }],
        }]

    if browser == "firefox":
        return [{
            "name": "selenium",
            "image": SELENIUM_STANDALONE_FIREFOX,
            "volumes": [{
                "name": "uploads",
                "path": "/uploads",
            }],
        }]

    return []

def waitForBrowserService():
    return [{
        "name": "wait-for-browser-service",
        "image": OC_CI_WAIT_FOR,
        "commands": [
            "wait-for -it selenium:4444 -t 300",
        ],
    }]

def installPnpm():
    return [{
        "name": "pnpm-install",
        "image": OC_CI_NODEJS,
        "environment": {
            "PLAYWRIGHT_BROWSERS_PATH": ".playwright",
        },
        "commands": [
            "pnpm config set store-dir ./.pnpm-store",
            "pnpm install",
        ],
    }]

def lint():
    return [{
        "name": "lint",
        "image": OC_CI_NODEJS,
        "commands": [
            "pnpm lint",
        ],
    }]

def buildDockerImage():
    return [{
        "name": "docker",
        "image": PLUGINS_DOCKER,
        "settings": {
            "username": {
                "from_secret": "docker_username",
            },
            "password": {
                "from_secret": "docker_password",
            },
            "auto_tag": True,
            "dockerfile": "docker/Dockerfile",
            "repo": "owncloud/web",
        },
        "when": {
            "ref": {
                "exclude": [
                    "refs/pull/**",
                ],
            },
        },
    }]

def determineReleasePackage(ctx):
    if ctx.build.event != "tag":
        return None

    matches = [p for p in WEB_PUBLISH_NPM_PACKAGES if ctx.build.ref.startswith("refs/tags/%s-v" % p)]
    if len(matches) > 0:
        return matches[0]

    return None

def determineReleaseVersion(ctx):
    package = determineReleasePackage(ctx)
    if package == None:
        return ctx.build.ref.replace("refs/tags/v", "")

    return ctx.build.ref.replace("refs/tags/" + package + "-v", "")

def buildRelease(ctx):
    steps = []
    package = determineReleasePackage(ctx)
    version = determineReleaseVersion(ctx)

    if package == None:
        steps += [
            {
                "name": "make",
                "image": OC_CI_NODEJS,
                "commands": [
                    "cd %s" % dir["web"],
                    "make -f Makefile.release",
                ],
            },
            {
                "name": "changelog",
                "image": TOOLHIPPIE_CALENS,
                "commands": [
                    "calens --version %s -o dist/CHANGELOG.md -t changelog/CHANGELOG-Release.tmpl" % version.split("-")[0],
                ],
                "when": {
                    "ref": [
                        "refs/tags/**",
                    ],
                },
            },
            {
                "name": "publish",
                "image": PLUGINS_GITHUB_RELEASE,
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "release/*",
                    ],
                    "checksum": [
                        "md5",
                        "sha256",
                    ],
                    "title": ctx.build.ref.replace("refs/tags/v", ""),
                    "note": "dist/CHANGELOG.md",
                    "overwrite": True,
                },
                "when": {
                    "ref": [
                        "refs/tags/**",
                    ],
                },
            },
        ]
    else:
        steps.append(
            {
                "name": "publish",
                "image": OC_CI_NODEJS,
                "environment": {
                    "NPM_TOKEN": {
                        "from_secret": "npm_token",
                    },
                },
                "commands": [
                    "echo " + package + " " + version,
                    "[ \"$(jq -r '.version'  < packages/%s/package.json)\" = \"%s\" ] || (echo \"git tag does not match version in packages/%s/package.json\"; exit 1)" % (package, version, package),
                    "git checkout .",
                    "git clean -fd",
                    "git diff",
                    "git status",
                    # until https://github.com/pnpm/pnpm/issues/5775 is resolved, we print pnpm whoami because that fails when the npm_token is invalid
                    "env \"npm_config_//registry.npmjs.org/:_authToken=$${NPM_TOKEN}\" pnpm whoami",
                    "env \"npm_config_//registry.npmjs.org/:_authToken=$${NPM_TOKEN}\" pnpm publish --no-git-checks --filter %s --access public --tag latest" % ("%s/%s" % (WEB_PUBLISH_NPM_ORGANIZATION, package)),
                ],
                "when": {
                    "ref": [
                        "refs/tags/**",
                    ],
                },
            },
        )

    return steps

def documentation(ctx):
    return [
        {
            "kind": "pipeline",
            "type": "docker",
            "name": "documentation",
            "platform": {
                "os": "linux",
                "arch": "amd64",
            },
            "steps": [
                {
                    "name": "prepare",
                    "image": OC_CI_ALPINE,
                    "commands": [
                        "make docs-copy",
                    ],
                },
                {
                    "name": "test",
                    "image": OC_CI_HUGO,
                    "commands": [
                        "cd hugo",
                        "hugo",
                    ],
                },
                {
                    "name": "list",
                    "image": OC_CI_ALPINE,
                    "commands": [
                        "tree hugo/public",
                    ],
                },
                {
                    "name": "publish",
                    "image": PLUGINS_GH_PAGES,
                    "settings": {
                        "username": {
                            "from_secret": "github_username",
                        },
                        "password": {
                            "from_secret": "github_token",
                        },
                        "pages_directory": "docs/",
                        "copy_contents": "true",
                        "target_branch": "docs",
                    },
                    "when": {
                        "ref": {
                            "exclude": [
                                "refs/pull/**",
                            ],
                        },
                    },
                },
            ],
            "trigger": {
                "ref": [
                    "refs/heads/master",
                    "refs/heads/stable-*",
                    "refs/pull/**",
                ],
            },
        },
    ]

def getSkeletonFiles():
    return [{
        "name": "setup-skeleton-files",
        "image": OC_CI_PHP,
        "commands": [
            "git clone https://github.com/owncloud/testing.git /srv/app/testing",
        ],
        "volumes": [{
            "name": "gopath",
            "path": dir["app"],
        }],
    }]

def webService():
    return [{
        "name": "web",
        "image": OC_CI_PHP,
        "environment": {
            "APACHE_WEBROOT": "%s/dist" % dir["web"],
            "APACHE_LOGGING_PATH": "/dev/null",
        },
        "commands": [
            "mkdir -p %s/dist" % dir["web"],
            "/usr/local/bin/apachectl -D FOREGROUND",
        ],
    }]

def ocisService(type, tika_enabled = False):
    environment = {
        "IDM_ADMIN_PASSWORD": "admin",  # override the random admin password from `ocis init`
        "IDP_IDENTIFIER_REGISTRATION_CONF": "%s" % dir["ocisIdentifierRegistrationConfig"],
        "OCIS_INSECURE": "true",
        "OCIS_LOG_LEVEL": "error",
        "OCIS_URL": "https://ocis:9200",
        "LDAP_GROUP_SUBSTRING_FILTER_TYPE": "any",
        "LDAP_USER_SUBSTRING_FILTER_TYPE": "any",
        "PROXY_ENABLE_BASIC_AUTH": True,
        "WEB_ASSET_PATH": "%s/dist" % dir["web"],
        "FRONTEND_SEARCH_MIN_LENGTH": "2",
        "FRONTEND_OCS_ENABLE_DENIALS": True,
    }
    if type == "app-provider":
        environment["GATEWAY_GRPC_ADDR"] = "0.0.0.0:9142"
        environment["MICRO_REGISTRY"] = "mdns"
    else:
        environment["WEB_UI_CONFIG_FILE"] = "%s" % dir["ocisConfig"]
        environment["STORAGE_HOME_DRIVER"] = "ocis"
        environment["STORAGE_METADATA_DRIVER_OCIS_ROOT"] = "/srv/app/tmp/ocis/storage/metadata"
        environment["STORAGE_SHARING_USER_JSON_FILE"] = "/srv/app/tmp/ocis/shares.json"
        environment["STORAGE_USERS_DRIVER"] = "ocis"
        environment["STORAGE_USERS_DRIVER_LOCAL_ROOT"] = "/srv/app/tmp/ocis/local/root"
        environment["STORAGE_USERS_DRIVER_OCIS_ROOT"] = "/srv/app/tmp/ocis/storage/users"
        environment["STORAGE_USERS_DRIVER_OWNCLOUD_DATADIR"] = "%s" % dir["ocisRevaDataRoot"]

    if tika_enabled:
        environment["FRONTEND_FULL_TEXT_SEARCH_ENABLED"] = True
        environment["SEARCH_EXTRACTOR_TYPE"] = "tika"
        environment["SEARCH_EXTRACTOR_TIKA_TIKA_URL"] = "http://tika:9998"
        environment["SEARCH_EXTRACTOR_CS3SOURCE_INSECURE"] = True

    return [
        {
            "name": "ocis",
            "image": OC_CI_GOLANG,
            "detach": True,
            "environment": environment,
            "commands": [
                "cd %s" % dir["ocis"],
                "mkdir -p %s" % dir["ocisRevaDataRoot"],
                "mkdir -p /srv/app/tmp/ocis/storage/users/",
                "./ocis init",
                "cp %s/tests/drone/app-registry.yaml /root/.ocis/config/app-registry.yaml" % dir["web"],
                "./ocis server",
            ],
            "volumes": [{
                "name": "gopath",
                "path": dir["app"],
            }, {
                "name": "configs",
                "path": dir["config"],
            }, {
                "name": "ocis-config",
                "path": "/root/.ocis/config",
            }],
        },
        {
            "name": "wait-for-ocis-server",
            "image": OC_CI_WAIT_FOR,
            "commands": [
                "wait-for -it ocis:9200 -t 300",
            ],
        },
    ]

def checkForExistingOcisCache(ctx):
    web_repo_path = "https://raw.githubusercontent.com/owncloud/web/%s" % ctx.build.commit
    return [
        {
            "name": "check-for-existing-cache",
            "image": OC_UBUNTU,
            "environment": minio_mc_environment,
            "commands": [
                "curl -o .drone.env %s/.drone.env" % web_repo_path,
                "curl -o check-oCIS-cache.sh %s/tests/drone/check-oCIS-cache.sh" % web_repo_path,
                ". ./.drone.env",
                "bash check-oCIS-cache.sh",
            ],
        },
    ]

def setupServerConfigureWeb(logLevel):
    return [{
        "name": "setup-server-configure-web",
        "image": OC_CI_PHP,
        "commands": [
            "mkdir -p /srv/config",
            "cp -r %s/tests/drone /srv/config" % dir["web"],
            "ls -la /srv/config/drone",
        ],
        "volumes": [{
            "name": "configs",
            "path": dir["config"],
        }],
    }]

def copyFilesForUpload():
    return [{
        "name": "copy-files-for-upload",
        "image": OC_CI_PHP,
        "volumes": [{
            "name": "uploads",
            "path": "/filesForUpload",
        }],
        "commands": [
            "ls -la /filesForUpload",
            "cp -a %s/tests/e2e/filesForUpload/. /filesForUpload" % dir["web"],
            "ls -la /filesForUpload",
        ],
    }]

def runWebuiAcceptanceTests(ctx, suite, alternateSuiteName, filterTags, extraEnvironment, screenShots, retry):
    environment = {}
    if (filterTags != ""):
        environment["TEST_TAGS"] = filterTags

    environment["LOCAL_UPLOAD_DIR"] = "/uploads"
    if type(suite) == "list":
        paths = ""
        for path in suite:
            paths = paths + "features/" + path + " "
        environment["TEST_PATHS"] = paths
    elif (suite != "all"):
        environment["TEST_CONTEXT"] = suite

    if (ctx.build.event == "cron") or (not retry):
        environment["RERUN_FAILED_WEBUI_SCENARIOS"] = "false"
    if (screenShots):
        environment["SCREENSHOTS"] = "true"
    environment["SERVER_HOST"] = "http://web"
    environment["BACKEND_HOST"] = "http://owncloud"
    environment["COMMENTS_FILE"] = "%s" % dir["commentsFile"]
    environment["MIDDLEWARE_HOST"] = "http://middleware:3000"
    environment["REMOTE_UPLOAD_DIR"] = "/usr/src/app/filesForUpload"
    environment["WEB_UI_CONFIG_FILE"] = "%s/dist/config.json" % dir["web"]

    for env in extraEnvironment:
        environment[env] = extraEnvironment[env]

    return restoreBuildArtifactCache(ctx, "pnpm", ".pnpm-store") + [{
        "name": "webui-acceptance-tests",
        "image": OC_CI_NODEJS,
        "environment": environment,
        "commands": [
            "pnpm config set store-dir ./.pnpm-store",
            "pnpm install",  # FIXME: use --filter ./tests/acceptance (currently @babel/register is not found)
            "cd %s/tests/acceptance && ./run.sh" % dir["web"],
        ],
        "volumes": [{
            "name": "gopath",
            "path": dir["app"],
        }, {
            "name": "configs",
            "path": dir["config"],
        }],
    }]

def cacheOcisPipeline(ctx):
    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "cache-ocis",
        "workspace": web_workspace,
        "clone": {
            "disable": True,
        },
        "steps": checkForExistingOcisCache(ctx) +
                 buildOcis() +
                 cacheOcis(),
        "volumes": [{
            "name": "gopath",
            "temp": {},
        }],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }]

def restoreOcisCache():
    return [{
        "name": "restore-ocis-cache",
        "image": MINIO_MC,
        "environment": minio_mc_environment,
        "commands": [
            ". ./.drone.env",
            "rm -rf %s" % dir["ocis"],
            "mkdir -p %s" % dir["ocis"],
            "mc alias set s3 $MC_HOST $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY",
            "mc cp -r -a s3/$CACHE_BUCKET/ocis-build/$OCIS_COMMITID/ocis %s" % dir["ocis"],
        ],
    }]

def buildOcis():
    ocis_repo_url = "https://github.com/owncloud/ocis.git"
    return [
        {
            "name": "clone-ocis",
            "image": OC_CI_GOLANG,
            "commands": [
                "source .drone.env",
                "cd $GOPATH/src",
                "mkdir -p github.com/owncloud",
                "cd github.com/owncloud",
                "git clone -b $OCIS_BRANCH --single-branch %s" % ocis_repo_url,
                "cd ocis",
                "git checkout $OCIS_COMMITID",
            ],
            "volumes": go_step_volumes,
        },
        {
            "name": "generate-ocis",
            "image": OC_CI_NODEJS,
            "commands": [
                # we cannot use the $GOPATH here because of different base image
                "cd /go/src/github.com/owncloud/ocis/",
                "retry -t 3 'make ci-node-generate'",
            ],
            "volumes": go_step_volumes,
        },
        {
            "name": "build-ocis",
            "image": OC_CI_GOLANG,
            "commands": [
                "source .drone.env",
                "cd $GOPATH/src/github.com/owncloud/ocis/ocis",
                "retry -t 3 'make build'",
                "mkdir -p %s/$OCIS_COMMITID" % dir["base"],
                "cp bin/ocis %s/$OCIS_COMMITID" % dir["base"],
            ],
            "volumes": go_step_volumes,
        },
    ]

def cacheOcis():
    return [{
        "name": "upload-ocis-cache",
        "image": MINIO_MC,
        "environment": minio_mc_environment,
        "commands": [
            ". ./.drone.env",
            "mc alias set s3 $MC_HOST $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY",
            "mc cp -r -a %s/$OCIS_COMMITID/ocis s3/$CACHE_BUCKET/ocis-build/$OCIS_COMMITID" % dir["base"],
            "mc ls --recursive s3/$CACHE_BUCKET/ocis-build",
        ],
    }]

def uploadScreenshots():
    return [{
        "name": "upload-screenshots",
        "image": PLUGINS_S3,
        "pull": "if-not-exists",
        "settings": {
            "bucket": {
                "from_secret": "cache_public_s3_bucket",
            },
            "endpoint": {
                "from_secret": "cache_public_s3_server",
            },
            "path_style": True,
            "source": "%s/tests/acceptance/reports/screenshots/**/*" % dir["web"],
            "strip_prefix": "%s/tests/acceptance/reports/screenshots" % dir["web"],
            "target": "/${DRONE_REPO}/${DRONE_BUILD_NUMBER}/screenshots",
        },
        "environment": {
            "AWS_ACCESS_KEY_ID": {
                "from_secret": "cache_public_s3_access_key",
            },
            "AWS_SECRET_ACCESS_KEY": {
                "from_secret": "cache_public_s3_secret_key",
            },
        },
        "when": {
            "status": [
                "failure",
            ],
            "event": [
                "pull_request",
            ],
        },
    }]

def example_deploys(ctx):
    on_merge_deploy = [
        "ocis_web/latest.yml",
    ]
    nightly_deploy = [
        "ocis_web/daily.yml",
    ]

    # if on master branch:
    configs = on_merge_deploy
    rebuild = "false"

    if ctx.build.event == "tag":
        configs = nightly_deploy
        rebuild = "false"

    if ctx.build.event == "cron":
        configs = on_merge_deploy + nightly_deploy
        rebuild = "true"

    deploys = []
    for config in configs:
        deploys.append(deploy(ctx, config, rebuild))

    return deploys

def deploy(ctx, config, rebuild):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "deploy_%s" % (config),
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "clone continuous deployment playbook",
                "image": ALPINE_GIT,
                "commands": [
                    "cd deployments/continuous-deployment-config",
                    "git clone https://github.com/owncloud-devops/continuous-deployment.git",
                ],
            },
            {
                "name": "deploy",
                "image": OC_CI_DRONE_ANSIBLE,
                "failure": "ignore",
                "environment": {
                    "CONTINUOUS_DEPLOY_SERVERS_CONFIG": "../%s" % (config),
                    "REBUILD": "%s" % (rebuild),
                    "HCLOUD_API_TOKEN": {
                        "from_secret": "hcloud_api_token",
                    },
                    "CLOUDFLARE_API_TOKEN": {
                        "from_secret": "cloudflare_api_token",
                    },
                },
                "settings": {
                    "playbook": "deployments/continuous-deployment-config/continuous-deployment/playbook-all.yml",
                    "galaxy": "deployments/continuous-deployment-config/continuous-deployment/requirements.yml",
                    "requirements": "deployments/continuous-deployment-config/continuous-deployment/py-requirements.txt",
                    "inventory": "localhost",
                    "private_key": {
                        "from_secret": "ssh_private_key",
                    },
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
            ],
        },
    }

def checkStarlark():
    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "check-starlark",
        "steps": [
            {
                "name": "format-check-starlark",
                "image": OC_CI_BAZEL_BUILDIFIER,
                "commands": [
                    "buildifier --mode=check .drone.star",
                ],
            },
            {
                "name": "show-diff",
                "image": OC_CI_BAZEL_BUILDIFIER,
                "commands": [
                    "buildifier --mode=fix .drone.star",
                    "git diff",
                ],
                "when": {
                    "status": [
                        "failure",
                    ],
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/pull/**",
            ],
        },
    }]

def licenseCheck(ctx):
    return [{
        "kind": "pipeline",
        "type": "docker",
        "name": "license-check",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "pnpm-install",
                "image": OC_CI_NODEJS,
                "commands": [
                    "pnpm config set store-dir ./.pnpm-store",
                    "pnpm install",
                ],
            },
            {
                "name": "node-check-licenses",
                "image": OC_CI_NODEJS,
                "commands": [
                    "pnpm licenses:check",
                ],
            },
            {
                "name": "node-save-licenses",
                "image": OC_CI_NODEJS,
                "commands": [
                    "pnpm licenses:csv",
                    "pnpm licenses:save",
                ],
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }]

def middlewareService():
    environment = {
        "BACKEND_HOST": "https://ocis:9200",
        "OCIS_REVA_DATA_ROOT": "/srv/app/tmp/ocis/storage/owncloud/",
        "RUN_ON_OCIS": "true",
        "REMOTE_UPLOAD_DIR": "/uploads",
        "NODE_TLS_REJECT_UNAUTHORIZED": "0",
        "MIDDLEWARE_HOST": "middleware",
        "TEST_WITH_GRAPH_API": "true",
    }

    return [{
        "name": "middleware",
        "image": OC_TESTING_MIDDLEWARE,
        "environment": environment,
        "volumes": [{
            "name": "gopath",
            "path": dir["app"],
        }, {
            "name": "uploads",
            "path": "/uploads",
        }],
    }]

def waitForMiddlewareService():
    return [{
        "name": "wait-for-middleware-service",
        "image": OC_CI_WAIT_FOR,
        "commands": [
            "wait-for -it middleware:3000 -t 300",
        ],
    }]

def pipelineDependsOn(pipeline, dependant_pipelines):
    if "depends_on" in pipeline.keys():
        pipeline["depends_on"] = pipeline["depends_on"] + getPipelineNames(dependant_pipelines)
    else:
        pipeline["depends_on"] = getPipelineNames(dependant_pipelines)
    return pipeline

def pipelinesDependsOn(pipelines, dependant_pipelines):
    pipes = []
    for pipeline in pipelines:
        pipes.append(pipelineDependsOn(pipeline, dependant_pipelines))

    return pipes

def getPipelineNames(pipelines = []):
    """getPipelineNames returns names of pipelines as a string array

    Args:
      pipelines: array of drone pipelines

    Returns:
      names of the given pipelines as string array
    """
    names = []
    for pipeline in pipelines:
        names.append(pipeline["name"])
    return names

def skipIfUnchanged(ctx, type):
    if ("full-ci" in ctx.build.title.lower()):
        return []

    skip_step = {
        "name": "skip-if-unchanged",
        "image": OC_CI_DRONE_SKIP_PIPELINE,
        "when": {
            "event": [
                "pull_request",
            ],
        },
    }

    base_skip_steps = [
        "^.github/.*",
        "^changelog/.*",
        "^config/.*",
        "^deployments/.*",
        "^dev/.*",
        "^docs/.*",
        "^packages/web-app-skeleton/.*",
        "README.md",
    ]

    if type == "cache" or type == "lint":
        skip_step["settings"] = {
            "ALLOW_SKIP_CHANGED": base_skip_steps,
        }
        return [skip_step]

    if type == "acceptance-tests":
        acceptance_skip_steps = [
            "^__fixtures__/.*",
            "^__mocks__/.*",
            "^packages/.*/tests/.*",
            "^tests/e2e/.*",
            "^tests/unit/.*",
        ]
        skip_step["settings"] = {
            "ALLOW_SKIP_CHANGED": base_skip_steps + acceptance_skip_steps,
        }
        return [skip_step]

    if type == "e2e-tests":
        e2e_skip_steps = [
            "^__fixtures__/.*",
            "^__mocks__/.*",
            "^packages/.*/tests/.*",
            "^tests/acceptance/.*",
            "^tests/unit/.*",
        ]
        skip_step["settings"] = {
            "ALLOW_SKIP_CHANGED": base_skip_steps + e2e_skip_steps,
        }
        return [skip_step]

    if type == "unit-tests":
        unit_skip_steps = [
            "^tests/acceptance/.*",
        ]
        skip_step["settings"] = {
            "ALLOW_SKIP_CHANGED": base_skip_steps + unit_skip_steps,
        }
        return [skip_step]

    return []

def genericCache(name, action, mounts, cache_path):
    rebuild = "false"
    restore = "false"
    if action == "rebuild":
        rebuild = "true"
        action = "rebuild"
    else:
        restore = "true"
        action = "restore"

    step = {
        "name": "%s_%s" % (action, name),
        "image": PLUGINS_S3_CACHE,
        "settings": {
            "endpoint": {
                "from_secret": "cache_s3_server",
            },
            "rebuild": rebuild,
            "restore": restore,
            "mount": mounts,
            "access_key": {
                "from_secret": "cache_s3_access_key",
            },
            "secret_key": {
                "from_secret": "cache_s3_secret_key",
            },
            "filename": "%s.tar" % (name),
            "path": cache_path,
            "fallback_path": cache_path,
        },
    }
    return step

def genericCachePurge(flush_path):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "purge_build_artifact_cache",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "purge-cache",
                "image": PLUGINS_S3_CACHE,
                "settings": {
                    "access_key": {
                        "from_secret": "cache_s3_access_key",
                    },
                    "endpoint": {
                        "from_secret": "cache_s3_server",
                    },
                    "secret_key": {
                        "from_secret": "cache_s3_secret_key",
                    },
                    "flush": True,
                    "flush_age": 1,
                    "flush_path": flush_path,
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/stable-*",
                "refs/tags/**",
                "refs/pull/**",
            ],
            "status": [
                "success",
                "failure",
            ],
        },
    }

def genericBuildArtifactCache(ctx, name, action, path):
    if action == "rebuild" or action == "restore":
        cache_path = "%s/%s/%s" % ("cache", ctx.repo.slug, ctx.build.commit + "-${DRONE_BUILD_NUMBER}")
        name = "%s_build_artifact_cache" % (name)
        return genericCache(name, action, [path], cache_path)

    if action == "purge":
        flush_path = "%s/%s" % ("cache", ctx.repo.slug)
        return genericCachePurge(flush_path)
    return []

def restoreBuildArtifactCache(ctx, name, path):
    return [genericBuildArtifactCache(ctx, name, "restore", path)]

def rebuildBuildArtifactCache(ctx, name, path):
    return [genericBuildArtifactCache(ctx, name, "rebuild", path)]

def purgeBuildArtifactCache(ctx):
    return genericBuildArtifactCache(ctx, "", "purge", [])

def pipelineSanityChecks(ctx, pipelines):
    """pipelineSanityChecks helps the CI developers to find errors before running it

    These sanity checks are only executed on when converting starlark to yaml.
    Error outputs are only visible when the conversion is done with the drone cli.

    Args:
      ctx: drone passes a context with information which the pipeline can be adapted to
      pipelines: pipelines to be checked, normally you should run this on the return value of main()

    Returns:
      none
    """

    # check if name length of pipeline and steps are exceeded.
    max_name_length = 50
    for pipeline in pipelines:
        pipeline_name = pipeline["name"]
        if len(pipeline_name) > max_name_length:
            print("Error: pipeline name %s is longer than 50 characters" % (pipeline_name))

        for step in pipeline["steps"]:
            step_name = step["name"]
            if len(step_name) > max_name_length:
                print("Error: step name %s in pipeline %s is longer than 50 characters" % (step_name, pipeline_name))

    # check for non existing depends_on
    possible_depends = []
    for pipeline in pipelines:
        possible_depends.append(pipeline["name"])

    for pipeline in pipelines:
        if "depends_on" in pipeline.keys():
            for depends in pipeline["depends_on"]:
                if not depends in possible_depends:
                    print("Error: depends_on %s for pipeline %s is not defined" % (depends, pipeline["name"]))

    # check for non declared volumes
    for pipeline in pipelines:
        pipeline_volumes = []
        if "volumes" in pipeline.keys():
            for volume in pipeline["volumes"]:
                pipeline_volumes.append(volume["name"])

        for step in pipeline["steps"]:
            if "volumes" in step.keys():
                for volume in step["volumes"]:
                    if not volume["name"] in pipeline_volumes:
                        print("Warning: volume %s for step %s is not defined in pipeline %s" % (volume["name"], step["name"], pipeline["name"]))

    # list used docker images
    print("")
    print("List of used docker images:")

    images = {}

    for pipeline in pipelines:
        for step in pipeline["steps"]:
            image = step["image"]
            if image in images.keys():
                images[image] = images[image] + 1
            else:
                images[image] = 1

    for image in images.keys():
        print(" %sx\t%s" % (images[image], image))

def logAcceptanceTestsScreenshotsResult(suite):
    return [{
        "name": "log-acceptance-tests-screenshot",
        "image": OC_UBUNTU,
        "commands": [
            "cd %s/tests/acceptance/reports/screenshots/" % dir["web"],
            'echo "To see the screenshots, please visit the following path"',
            'for f in *.png; do echo "### $f\n" \'!\'"(https://cache.owncloud.com/public/${DRONE_REPO}/${DRONE_BUILD_NUMBER}/screenshots/$f) \n"; done',
        ],
        "when": {
            "status": [
                "failure",
            ],
            "event": [
                "pull_request",
            ],
        },
    }]

def uploadTracingResult(ctx):
    status = ["failure"]
    if ("with-tracing" in ctx.build.title.lower()):
        status = ["failure", "success"]

    return [{
        "name": "upload-tracing-result",
        "image": PLUGINS_S3,
        "pull": "if-not-exists",
        "settings": {
            "bucket": {
                "from_secret": "cache_public_s3_bucket",
            },
            "endpoint": {
                "from_secret": "cache_public_s3_server",
            },
            "path_style": True,
            "source": "%s/reports/e2e/playwright/tracing/**/*" % dir["web"],
            "strip_prefix": "%s/reports/e2e/playwright/tracing" % dir["web"],
            "target": "/${DRONE_REPO}/${DRONE_BUILD_NUMBER}/tracing",
        },
        "environment": {
            "AWS_ACCESS_KEY_ID": {
                "from_secret": "cache_public_s3_access_key",
            },
            "AWS_SECRET_ACCESS_KEY": {
                "from_secret": "cache_public_s3_secret_key",
            },
        },
        "when": {
            "status": status,
            "event": [
                "pull_request",
                "cron",
            ],
        },
    }]

def logTracingResult(ctx, suite):
    status = ["failure"]

    if ("with-tracing" in ctx.build.title.lower()):
        status = ["failure", "success"]

    return [{
        "name": "log-tracing-result",
        "image": OC_UBUNTU,
        "commands": [
            "cd %s/reports/e2e/playwright/tracing/" % dir["web"],
            'echo "To see the trace, please open the following link in the console"',
            'for f in *.zip; do echo "npx playwright show-trace https://cache.owncloud.com/public/${DRONE_REPO}/${DRONE_BUILD_NUMBER}/tracing/$f \n"; done',
        ],
        "when": {
            "status": status,
            "event": [
                "pull_request",
                "cron",
            ],
        },
    }]

def tikaService():
    return [
        {
            "name": "tika",
            "type": "docker",
            "image": APACHE_TIKA,
            "detach": True,
        },
        {
            "name": "wait-for-tika-service",
            "image": OC_CI_WAIT_FOR,
            "commands": [
                "wait-for -it tika:9998 -t 300",
            ],
        },
    ]

def wopiServer():
    return [
        {
            "name": "wopiserver",
            "type": "docker",
            "image": "cs3org/wopiserver:v9.4.1",
            "detach": True,
            "commands": [
                "echo 'LoremIpsum567' > /etc/wopi/wopisecret",
                "cp %s/tests/drone/wopiserver/wopiserver.conf /etc/wopi/wopiserver.conf" % dir["web"],
                "/app/wopiserver.py",
            ],
        },
        {
            "name": "wait-for-wopi-server",
            "image": OC_CI_WAIT_FOR,
            "commands": [
                "wait-for -it wopiserver:8880 -t 300",
            ],
        },
    ]

def collaboraService():
    return [
        {
            "name": "collabora",
            "type": "docker",
            "image": "collabora/code:22.05.14.3.1",
            "detach": True,
            "environment": {
                "DONT_GEN_SSL_CERT": "set",
                "extra_params": "--o:ssl.enable=true --o:ssl.termination=true --o:welcome.enable=false --o:net.frame_ancestors=https://ocis:9200",
            },
        },
        {
            "name": "wait-for-collabora-service",
            "image": OC_CI_WAIT_FOR,
            "commands": [
                "wait-for -it collabora:9980 -t 300",
            ],
        },
    ]

def onlyofficeService():
    return [
        {
            "name": "onlyoffice",
            "type": "docker",
            "image": "onlyoffice/documentserver:7.3.3",
            "detach": True,
            "environment": {
                "WOPI_ENABLED": "true",
                "USE_UNAUTHORIZED_STORAGE": "true",  # self signed certificates
            },
            "commands": [
                "cp %s/tests/drone/onlyoffice/local.json /etc/onlyoffice/documentserver/local.json" % dir["web"],
                "openssl req -x509 -newkey rsa:4096 -keyout onlyoffice.key -out onlyoffice.crt -sha256 -days 365 -batch -nodes",
                "mkdir -p /var/www/onlyoffice/Data/certs",
                "cp onlyoffice.key /var/www/onlyoffice/Data/certs/",
                "cp onlyoffice.crt /var/www/onlyoffice/Data/certs/",
                "chmod 400 /var/www/onlyoffice/Data/certs/onlyoffice.key",
                "/app/ds/run-document-server.sh",
            ],
        },
        {
            "name": "wait-for-onlyoffice-service",
            "image": OC_CI_WAIT_FOR,
            "commands": [
                "wait-for -it onlyoffice:443 -t 300",
            ],
        },
    ]

def appProviderService(name):
    environment = {
        "APP_PROVIDER_LOG_LEVEL": "error",
        "REVA_GATEWAY": "com.owncloud.api.gateway",
        "APP_PROVIDER_GRPC_ADDR": "0.0.0.0:9164",
        "APP_PROVIDER_DRIVER": "wopi",
        "APP_PROVIDER_WOPI_INSECURE": True,
        "APP_PROVIDER_WOPI_WOPI_SERVER_EXTERNAL_URL": "http://wopiserver:8880",
        "APP_PROVIDER_WOPI_FOLDER_URL_BASE_URL": "https://ocis:9200",
        "MICRO_REGISTRY": "mdns",
    }

    if name == "collabora":
        environment["APP_PROVIDER_SERVICE_NAME"] = "app-provider-collabora"
        environment["APP_PROVIDER_EXTERNAL_ADDR"] = "com.owncloud.api.app-provider-collabora"
        environment["APP_PROVIDER_WOPI_APP_NAME"] = "Collabora"
        environment["APP_PROVIDER_WOPI_APP_ICON_URI"] = "https://collabora:9980/favicon.ico"
        environment["APP_PROVIDER_WOPI_APP_URL"] = "https://collabora:9980"
    elif name == "onlyoffice":
        environment["APP_PROVIDER_SERVICE_NAME"] = "app-provider-onlyoffice"
        environment["APP_PROVIDER_EXTERNAL_ADDR"] = "com.owncloud.api.app-provider-onlyoffice"
        environment["APP_PROVIDER_WOPI_APP_NAME"] = "OnlyOffice"
        environment["APP_PROVIDER_WOPI_APP_ICON_URI"] = "https://onlyoffice/web-apps/apps/documenteditor/main/resources/img/favicon.ico"
        environment["APP_PROVIDER_WOPI_APP_URL"] = "https://onlyoffice"

    return [
        {
            "name": "%s-app-provider" % name,
            "image": OC_CI_GOLANG,
            "detach": True,
            "environment": environment,
            "commands": [
                "cd %s" % dir["ocis"],
                "./ocis app-provider server",
            ],
            "volumes": [
                {
                    "name": "gopath",
                    "path": dir["app"],
                },
                {
                    "name": "ocis-config",
                    "path": "/root/.ocis/config",
                },
            ],
        },
    ]
