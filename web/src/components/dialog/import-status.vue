<template>
  <div class="import-status">
    <div class="img-wrap">
      <img src="./import-status.svg"/>
      <div>
        <i class="icon-gap icon aufontAll h-icon-all-close-circle"
           v-show="!validating && (systemError || showFailMessage)"></i>
        <i class="icon-gap icon success aufontAll h-icon-all-check-circle" v-show="!validating && (isHalfSuccess || isSuccessData)"></i>
      </div>
    </div>

    <div class="import-status-progress" v-if="validating">
      <a-progress :percent="progress"/>
      <p>数据导入中，请不要关闭页面...</p>
    </div>

    <div class="import-status-info" v-else>
      <p class="import-status-info--title">
        <template v-if="systemError">
          数据导入失败
        </template>
        <template v-if="isHalfSuccess || isSuccessData">
          数据导入完成
        </template>
        <template v-if="showFailMessage">
          数据校验错误
        </template>
      </p>

      <p v-if="systemError">
        {{ errMessage ? errMessage : '导入失败，请重新导入' }}
      </p>

      <p v-else-if="isSuccessData">
        成功导入<span class="success">{{ statusParams.successNum }}</span>条数据
      </p>

      <template v-else-if="isHalfSuccess">
        <p>
          成功导入<span class="success">{{ statusParams.successNum }}</span>条数据,有 <span class="fail">{{ statusParams.failNum }}</span>
          条数据导入失败
        </p>
        <p>请<span @click="onDownloadErrorFile" class="fail">下载错误数据</span>，修改后再导入</p>
      </template>
      <template v-else-if="showFailMessage">
        <p v-if="isUnspecified">{{ $t('cloudpivot.form.renderer.tip.importErrorRelation') }} </p>
        <p v-else-if="isTemplateEmpty">当前文件内的表单内容为空，请重新检查再导入数据</p>
        <p v-else-if="fileTypeError"> {{ $t('cloudpivot.form.renderer.tip.ImportTips3') }}</p>
        <p v-else-if="!matchError">{{ $t('cloudpivot.list.pc.ImportTips9', {size: statusParams.importSize}) }}</p>
        <div v-else>
          <p>{{statusParams.errorMsg}}</p>
          <p>请参照<a @click.stop="exportTemplate">{{ $t('cloudpivot.list.pc.SampleFile') }}</a>重新检查</p>
        </div>
      </template>


      <div class="import-status-info--action">
        <a-button @click="reupload" v-if="showFailMessage">
          重新上传
        </a-button>
        <a-button @click="setRenderData" v-if="isHalfSuccess || isSuccessData">
          完成
        </a-button>
        <a-button
          @click="reupload"
          v-if="systemError"
        >
          重新导入
        </a-button>
      </div>
    </div>
  </div>
</template>

<script>
import { enums } from '@/utils/enum'
export default {
    data() {
        return {
            state: enums.ImportState.PartialSuccess,
            validating: false,
            progress: 30,
            timer: null,
            isSuccess: false,
            isDownErrorFile: false,
            successNum: 0,
            failNum: 0,
            errMessage: '',
            successRecords: [],
            errorRefId: '',

        }
    },
    props: {
        statusParams: {
            type: Object
        },

    },
    computed: {
        isHalfSuccess() {
            return this.statusParams.importStatus === enums.ImportResult.PartialSuccess;
        },
        isUnspecified() {
            return this.statusParams.importStatus === enums.ImportResult.Unspecified;
        },
        isTemplateEmpty() {
            return this.statusParams.importStatus === enums.ImportResult.TemplateEmpty;
        },
        fileTypeError() {
            return this.statusParams.importStatus === enums.ImportResult.FileTypeError;
        },
        matchError() {
            return this.statusParams.importStatus === enums.ImportResult.DataColumnError;
        },
        systemError() {
            return this.statusParams.importStatus === enums.ImportResult.SystemError;
        },
        isSuccessData() {
            return this.statusParams.importStatus === enums.ImportResult.Success;
        },
        showFailMessage() {
            return this.statusParams.importStatus === enums.ImportResult.DataNumExceed
            || this.statusParams.importStatus === enums.ImportResult.DataColumnError
            || this.statusParams.importStatus === enums.ImportResult.FileTypeError
            || this.isUnspecified
            || this.isTemplateEmpty;
        },
    },
    created() {
      this.validating = true;
      this.startProgress();
    },
    methods: {
        // 下载文件
        downloadFile (blob, fileName) {
            if (navigator.msSaveOrOpenBlob) {
                navigator.msSaveBlob(blob, fileName);
            } else {
                const a = document.createElement('a');
                const url = URL.createObjectURL(blob);
                a.download = fileName;
                a.href = url;
                a.click();
                URL.revokeObjectURL(url);
            }
        },
        startProgress() {
            this.timer = setInterval(() => {
                this.progress += 10;
                if (this.progress === 90 && !this.isSuccess && !(this.statusParams.importStatus !== enums.ImportResult.Unspecified)) {
                    this.progress = 80;
                }
                if (this.progress === 100 && (this.isSuccess || (this.statusParams.importStatus || this.statusParams.importStatus === 0) && this.statusParams.importStatus !== enums.ImportResult.Unspecified)) {
                    clearInterval(this.timer);
                    this.validating = false;
                }
            }, 100);
        },
        reupload() {
            this.$emit('reupload');
        },
        setRenderData() {
            this.$emit('setRenderData', this.successRecords);
        },
        /**
         * 下载示例模板
         */
        async exportTemplate() {
            console.log("todo 下载示例模板")
        },
        /**
         * 下载错误信息文档
         */
        async onDownloadErrorFile() {
            console.log("todo 下载错误信息文档")
        },
    },
    destroyed() {
        clearInterval(this.timer);
    }
}
</script>

<style lang="less" scoped>
  .import-status {
    p {
      margin-bottom: 5px;
    }

    .img-wrap {
      width: 92px;
      margin: 85px auto;
      margin-bottom: 0;
      position: relative;

      & > div {
        // background: #fff;
        width: 39px;
        position: absolute;
        bottom: 0;
        right: 0;

        & > .icon {
          &.success {
            color: #17bc94;
          }

          font-size: 39px;
          color: #f4454e;
        }
      }
    }

    &-progress {
      text-align: center;
      width: 400px;
      margin: 49px auto;
      margin-bottom: 151px;

      p {
        font-size: 14px;
        color: rgba(0, 0, 0, 0.85);
        line-height: 22px;
        margin-top: 23px;
      }
    }

    &-info {
      text-align: center;
      width: 90%;
      margin: 34px auto;

      &--title {
        font-size: 14px;
        color: rgba(0, 0, 0, 0.85);
        line-height: 22px;
        font-weight: 600;
        margin-bottom: 8px;
      }

      & > p {
        & > span {
          &.success {
            color: #17bc94;
          }

          &.fail {
            color: #f4454e;
            cursor: pointer;
          }
        }
      }

      &--action {
        margin-top: 32px;
        margin-bottom: 79px;
      }
    }
  }
</style>