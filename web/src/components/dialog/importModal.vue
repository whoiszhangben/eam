<template>
  <div class="model-table-import">
    <a-modal
      :class="{'hide-footer': importStatusShow}"
      :maskClosable="false"
      :title="'导入数据'"
      :visible="true"
      @cancel="handleCancel"
      width="640px"
      wrapClassName="model-table-import"
    >
      <div>
        <!--导入弹窗组件-->
        <ImportInput
          :dataItems="dataItems"
          :isFormSheet="isFormSheet"
          :modelInfo="modelInfo"
          @resetUpLoad="reupload"
          @setCoverCode="setCoverCode"
          @setImportAble="setImportAble"
          @uploadComplete="uploadComplete"
          ref="importInput"
          v-if="importInputShow"
        />
        <!--导入状态-->
        <template>
          <img src="./import-status.svg" style="display: none"/>
          <ImportStatus
            :isFormSheet="isFormSheet"
            :showImportStatus="showImportStatus"
            :statusParams="statusParams"
            @reupload="reupload"
            @setRenderData="setRenderData"
            ref="importStatus"
            v-if="importStatusShow"
          />
        </template>
      </div>
      <template slot="footer">
        <a-button @click="handleCancel">
          取消
        </a-button>
        <a-button
          :disabled="forbiddenImport"
          @click="handleImport"
          type="primary"
        >
          导入
        </a-button>
      </template>
    </a-modal>
  </div>
</template>

<script>
import ImportInput from './importInput.vue';
import ImportStatus from './import-status.vue';
export default {
    name: 'ImportModal',
    components: {
        ImportInput,
        ImportStatus
    },
    props: ['isFormSheet'],
    data() {
        return {
            dataItems: [],
            modelInfo: {},
            importInputShow: true,
            importStatusShow: false,
            uploadCompleteStatus: false,
            coverStatus: false,
            coverCode: '',
            interval: null,
            timeout: null
        }
    },
    computed: {
        forbiddenImport() {
            if (this.uploadCompleteStatus && this.coverStatus && this.coverCode) {
                return false;
            } else if (
                this.uploadCompleteStatus &&
                !this.coverStatus &&
                this.coverCode
            ) {
                return false;
            } else if (
                this.uploadCompleteStatus &&
                !this.coverStatus &&
                !this.coverCode
            ) {
                return false;
            }
            return true;
        },

    },
    methods: {
        reupload() {
            this.importInputShow = true;
            this.importStatusShow = false;
            this.validateStatusShow = false;
            this.showDataFix = false;
            this.uploadCompleteStatus = false;
            this.$emit('reset');
        },
        // 判断是否有覆盖字段 禁止导入
        setImportAble(val) {
            this.coverStatus = val;
        },
        setCoverCode(code) {
            if (!code) {
                this.coverCode = false;
            } else {
                this.coverCode = code;
            }
        },
        // 导入成功后的渲染
        setRenderData(data) {
            this.$emit('setData', data);
            this.$emit('close');
        },
        // 上传完成
        uploadComplete(val) {
            this.uploadCompleteStatus = val;
        },
        // 取消修正数据重新导入
        closeDataFix() {
            this.reupload();
        },
        handleCancel() {
            this.uploadCompleteStatus = false;
            this.coverStatus = false;
            this.coverCode = false;
            this.$emit('close');
        },
        // 导入文件
        handleImport() {
            this.dataImport();
        },
        // 重置数据
        resetData(data) {
            this.dataList = data;
        },
        handleProgress(taskId) {
            this.interval = setInterval(() => {
                this.getImportProgress(taskId);
            }, 5000);
            //设置定时任务5分钟;
            if (this.interval) {
                this.timeout = setTimeout(() => {
                clearInterval(this.interval);
                this.$message.error('连接超时');
                }, 300000)
            }
        },

        async getImportProgress(taskId) {
            // todo 获取上传进度
            console.log(taskId)
        },
        // 校验成功后导入
        dataImport() {
            const importInput = this.$refs.importInput
            if (importInput) {
                this.importInputShow = false;
                this.importStatusShow = true;
                this.validateStatusShow = false;
                this.$nextTick(() => {
                    const importStatus = this.$refs.importStatus
                    const data = importInput.getTheData();
                    console.log(importStatus, data)
                    //  导入
                    // const params: listParams.ImportParams = {
                    //     fileName: data.file,
                    //     schemaCode: this.schemaCode,
                    //     queryCode: this.queryCode,
                    //     queryField: this.coverCode,
                    // };
                    // listApi.importData(params).then((res: any) => {
                    //     if (res.errcode !== 0) {
                    //     const msg: any = res.errmsg;
                    //     importStatus.setSate('fail', 0, 0, [], msg);
                    //     } else {
                    //     console.log(res, 'res');
                    //     const taskId = res.data.taskId || '';
                    //     this.handleProgress(taskId);
                    //     }
                    // })
                    //     .catch(() => {
                    //     importStatus.setSate('fail', 0, 0, [], '导入失败');
                    //     });
                });
            }

        }
    }

}
</script>

<style lang="less" scoped>
  .model-table-import {
    .ant-modal-body {
      padding-top: 16px;
    }

    .ant-modal-footer .ant-btn-primary:disabled {
      color: rgba(0, 0, 0, 0.45);
    }
  }

  .hide-footer {
    .ant-modal-footer {
      display: none;
    }
  }
</style>