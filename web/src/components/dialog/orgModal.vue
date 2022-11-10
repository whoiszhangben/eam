<template>
  <a-modal
    title="Title"
    :visible="visible"
    :confirm-loading="confirmLoading"
    @ok="handleOk"
    @cancel="handleCancel"
  >
      <p>{{ ModalText }}</p>
  </a-modal>
</template>

<script>
export default {
    data() {
        return {
            ModalText: 'Content of the modal',
            visible: false,
            confirmLoading: false,
        };
    },
    props: {
        opType: {
            type: Number,
            default: 0
        },
        currentNode: {
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
            this.ModalText = `当前打开的是节点${this.currentNode}, 执行的操作是${this.opType}`;
            this.confirmLoading = true;
            setTimeout(() => {
                this.visible = false;
                this.confirmLoading = false;
            }, 2000);
        },
        handleCancel() {
            this.$emit("closeDialog")
        },
    },
    watch: {
        isModalVisible(nVal) {
            if (nVal) {
                this.ModalText = `当前打开的是节点${this.currentNode}, 执行的操作是${this.opType}`;
                this.visible = true
                console.log("modal visible is true")
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