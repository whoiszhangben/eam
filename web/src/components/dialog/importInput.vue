<template>
  <div class="import-input">
    <!-- v-if="!isUploading" -->
    <div
      :class="{hover: isHover}"
      @mouseleave="isHover = false"
      @mouseover="isHover = true"
      class="import-input-upload"
      v-show="!isUploading"
    >
      <a-upload-dragger
        :accept="upLoadAccept"
        :beforeUpload="beforeUpload"
        @change="handleChange"
        :multiple="false"
        :action="uploadUrl"
        name="file"
        ref="fileUpload"
        :headers="header"
        @remove="remove"
      >
        <div class="import-input-upload-icon">
          <a-icon type="cloud-upload" />
          <p>选择或拖拽Excel文件上传</p>
        </div>

        <div class="import-input-upload-tips">
          <p>1、支持.xlsx格式，单次最多500条数据</p>
          <p>
            2、为确保上传数据与列表内容匹配，请先下载
            <a style="text-decoration: underline;" @click.stop="exportTemplate()">示例文件</a>
          </p>
        </div>
      </a-upload-dragger>
    </div>

    <div class="import-input-progress" v-show="isUploading">
      <div>
        <span class="success-import icon aufontAll h-icon-all-excel"></span>
        <p>
          <span>{{ file.name }}</span>(<span>{{ file.size | filterFileSize }}</span>)
          <a-icon @click="deleteFile" class="icon" type="close"/>
        </p>
        <a-progress size="small" :percent="progress" :status="progressStatus"/>
      </div>
    </div>

    <div class="import-input-cover">
      <a-checkbox @change="changeCheck" v-model="isCover"/>
      <span style="padding: 0 5px">允许覆盖数据，当资产编码相同时，则覆盖已有数据</span>
    </div>
  </div>
</template>

<script>
import { filters } from '@/utils/filters';
export default {
  name: 'ImportInput',
  data() {
      return {
        isUploading: false,
        isUploadsuccess: false,
        progress: 10,
        file: {},
        timer: null,
        blob: {},
        isCover: false,
        isHover: false,
        upLoadAccept: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        coverCode: '',
        dataList: [],
        uploadUrl: ''
      }
    },
    filters: {
      filterFileSize: filters.fileSize,
    },
    computed: {
      progressStatus() {
        if (this.progress !== 100) {
          return 'active';
        }
        return 'success';
      },
      header() {
        const token = localStorage.getItem('token');
        return {
          Authorization: `Bearer ${token}`,
        };
      }
    },
    methods: {
        beforeUpload(file) {
            const suffix = this.getSuffix(file.name, false);
            const isLt2M = file.size / 1024 / 1024 < 1000;
            if (!['xlsx'].includes(suffix)) {
                this.$message.error('文件格式不对，仅支持上传.xlsx格式的文件!');
                return false;
            } else if (!isLt2M) {
                this.$message.error('最大不能超过1000M!');
                return isLt2M;
            } else {
                this.getSuffix(file.name, true);
                return true;
            }
        },
        getSuffix(fileName, showLoading) {
            const index = fileName.lastIndexOf('.');
            const suffix = fileName.substring(index + 1);
            if (suffix && showLoading) {
                this.isUploading = true;
                this.imitateProgress();
            }
            return suffix;
        },
        // 静态上传动画
        imitateProgress() {
            this.timer = setInterval(() => {
                this.progress += 10;
                if (this.progress === 90 && !this.isUploadsuccess) {
                this.progress = 80;
                }
                if (this.progress === 100 && this.isUploadsuccess) {
                this.isUploadsuccess = false; 
                clearInterval(this.timer);
                }
            }, 100);
        },
        handleChange(info) {
            this.file = info.file;
            this.blob = info.file;
            if (info.file.status !== 'uploading') {
                // this.fileList = info.fileList;
            }
            if (info.file.status === 'done') {
                this.$emit('change', true);
                this.blob = info.file.response;
                this.$emit('setFileName', info.file.response);
                this.$emit('uploadComplete', true);
                this.isUploadsuccess = true;
            } else if (info.file.status === 'error') {
                this.isUploading = false;
                this.hasError = true;
                this.$emit('uploadComplete', false);
            } else if(info.file.status === 'removed'){
                //清除临时文件 todo
                console.log("删除临时文件")
            }
        },
        remove() {
            this.$emit('change', false);
        },
        // 是否选择覆盖字段
        changeSelect() {
          this.$emit('setCoverCode', this.coverCode);
        },
        deleteFile() {
          this.file = {};
          this.progress = 10;
          this.isUploading = false;
          clearInterval(this.timer);
          this.$emit('resetUpLoad');
          this.$emit('uploadComplete', false);
      },
      // 是否勾选覆盖
      changeCheck() {
        this.$emit('setImportAble', this.isCover);
      },

    }
}
</script>

<style lang="less" scoped>
  .import-input {
    .import-input-progress{
      .success-import{
        color: #52C41A;
        font-size: 48px;
      }
    }
    &-upload {
      /deep/ .ant-upload-drag {
        background: #fff;
        .ant-upload-btn {
          padding: 0 !important;
        }
      }

      /deep/ .ant-upload-list-item {
        display: none;
      }

      &.hover {
        /deep/ .ant-upload-drag {
          background: #f0f7ff;
        }

        /deep/ .import-input-upload-icon {
          color: @primary-color !important;

          & > p {
            color: @primary-color;
          }
          & > span {
            color: @primary-color;
          }
        }
      }

      /deep/ .import-input-upload-tips {
        padding: 15px 0 27px 0;
        text-align: center;
        font-size: 12px;
        color: rgba(0, 0, 0, 0.45);
        line-height: 24px;
        max-width: 350px;
        margin: 0 auto;
        text-align: left;
      }

      /deep/ .import-input-upload-icon {
        padding-top: 50px;

        & > .icon {
          font-size: 64px;
          color: #E2E2E2;
        }

        & > p {
          font-size: 14px;
          color: rgba(0, 0, 0, 0.85);
          line-height: 22px;
          /*margin-top: 10px;*/
        }
      }
    }

    &-progress {
      border: 1px dashed rgba(0, 0, 0, 0.25);
      border-radius: 4px;
      display: flex;
      align-items: center;
      text-align: center;

      & > div {
        margin: 0 auto;
        width: 400px;

        p {
          margin-top: 23px;

          .icon {
            color: rgba(0, 0, 0, 0.45);
            margin-left: 8px;
            cursor: pointer;
          }
        }
      }

      height: 282px;
    }

    &-cover {
      padding-top: 24px;

      .ant-select {
        width: 298px;
      }
    }
  }
</style>