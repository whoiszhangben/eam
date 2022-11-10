<template>
    <a-modal
      :title="title"
      :visible="visible"
      :confirm-loading="confirmLoading"
      @ok="handleOk"
      @cancel="handleCancel"
    >
    <a-form>
      <a-form-item
        label="账号"
        :labelCol="{span: 7}"
        :wrapperCol="{span: 13}"
      >
        <a-input placeholder="请输入账号"  />
      </a-form-item>
      <a-form-item
        label="姓名"
        :labelCol="{span: 7}"
        :wrapperCol="{span: 13}"
      >
      <a-input placeholder="请输入姓名" />
      </a-form-item>
      <a-form-item
        label="请选择角色"
        :labelCol="{span: 7}"
        :wrapperCol="{span: 13}"
        :required="false"
      >
        <a-select>
          <a-select-option value="1">管理员</a-select-option>
          <a-select-option value="2">用户</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item
        label="是否启用"
        :labelCol="{span: 7}"
        :wrapperCol="{span: 13}"
        :required="false"
      >
      <a-radio-group>
        <a-radio :value="1">
            是
        </a-radio>
        <a-radio :value="2">
            否
        </a-radio>
        </a-radio-group>
      </a-form-item>
      <a-form-item
        label="描述"
        :labelCol="{span: 7}"
        :wrapperCol="{span: 13}"
      >
        <a-textarea rows="4" placeholder="请输入描述"/>
      </a-form-item>
    </a-form>
    </a-modal>
  </template>
  
  <script>

  export default {
      data() {
          return {
              ModalText: 'Content of the modal',
              visible: false,
              confirmLoading: false,
              title: '新增用户'
          };
      },
      props: {
          opType: {
              type: Number,
              default: 0
          },
          isModalVisible: {
              type: Boolean,
              default: false
          } 
      },
      methods: {
          showModal() {
              this.visible = true;
          },
          handleOk() {
              this.confirmLoading = true;
              console.log()
          },
          handleCancel() {
              this.$emit("closeDialog")
          },
      },
      watch: {
          isModalVisible(nVal) {
              if (nVal) {
                  if (this.opType === 0) {
                    this.title = '新增用户'
                  } else if(this.opType === 1) {
                    this.title = '编辑用户'
                  } else if (this.opType === 2) {
                    this.title = '用户详情'
                  }
                  this.visible = true
              } else {
                  this.visible = false
                  console.log("modal visible is false")
              }
          }
      }
  }
  </script>
  
  <style>
  
  </style>