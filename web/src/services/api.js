//跨域代理前缀
const API_PROXY_PREFIX = '/eam'
const BASE_URL = process.env.NODE_ENV === 'production' ? process.env.VUE_APP_API_BASE_URL : API_PROXY_PREFIX
// const BASE_URL = process.env.VUE_APP_API_BASE_URL
module.exports = {
  /* 用户 */
  LOGIN: `${BASE_URL}/eam/account/login`,
  USERLIST: `${BASE_URL}/eam/account/query`,
  USERADD: `${BASE_URL}/eam/account/add`,
  USEREDIT: `${BASE_URL}/eam/account/modify`,
  USERDEL: `${BASE_URL}/eam/account/remove`,
  USERPWDEdit: `${BASE_URL}/eam/account/modifypassword`,
  /* 组织 */
  ORGQUERY: `${BASE_URL}/eam/organization/query`,
  ORGADD: `${BASE_URL}/eam/organization/add`,
  ORGEDIT: `${BASE_URL}/eam/organization/modify`,
  ORGDEL: `${BASE_URL}/eam/organization/remove`,
  /* 资产分类 */
  GSORTLIST: `${BASE_URL}/eam/gsort/query`,
  GSORTADD: `${BASE_URL}/eam/gsort/add`,
  GSORTEDIT: `${BASE_URL}/eam/gsort/modify`,
  GSORTDEL: `${BASE_URL}/eam/gsort/remove`,
  CHILDGSORTQUERY: `${BASE_URL}/eam/childgsort/query`,
  CHILDGSORTADD: `${BASE_URL}/eam/childgsort/add`,
  CHILDGSORTEDIT: `${BASE_URL}/eam/childgsort/modify`,
  CHILDGSORTDEL: `${BASE_URL}/eam/childgsort/remove`,
  /* 资产 */
  GOODSQUERY: `${BASE_URL}/eam/goods/query`,
  GOODSADD: `${BASE_URL}/eam/goods/add`,
  GOODSEDIT: `${BASE_URL}/eam/goods/modify`,
  GOODSDEL: `${BASE_URL}/eam/goods/remove`,
  GOODSIMPORT: `${BASE_URL}/eam/goods/import`,
  GOODSEXPORT: `${BASE_URL}/eam/goods/export`,
  /* 打印 */
  PRINT: `${BASE_URL}/eam/print/check`,
  PRINTALL: `${BASE_URL}/eam/print/all`,
  /* 维修 */
  REPAIRQUERY: `${BASE_URL}/eam/repair/query`,
  REPAIRADD: `${BASE_URL}/eam/repair/add`,
  REPAIREXPORT: `${BASE_URL}/eam/repair/export`,
  SCANQUERY: `${BASE_URL}/eam/goods/scanquery`,
  /* 统计 */
  Statistic: `${BASE_URL}/eam/simplestatistics/query`,
  /* 流水 */
  FLOWQUERY: `${BASE_URL}/eam/goodsflowing/query`,
  /* 分布 */
  DISTRIBUTE: `${BASE_URL}/eam/distribute/query`,
  /* 供应商 */
  VENDORADD: `${BASE_URL}/eam/vendor/add`,
  VENDORQUERY: `${BASE_URL}/eam/vendor/query`,
  VENDORDEL: `${BASE_URL}/eam/vendor/remove`,
  VENDOREDIT: `${BASE_URL}/eam/vendor/modify`,
  /* 打印机终端 */
  PRINTCLIENTS: `${BASE_URL}/eam/print/query`,
  /* 系统参数 */
  PARAMSQUERY: `${BASE_URL}/eam/config/query`,
  PARAMSEDIT: `${BASE_URL}/eam/config/modify`,
  /* 系统日志 */
  SYSTEMLOG: `${BASE_URL}/eam/log/query`,
  /* 模板 */
  GOODSTEMPLATE: `${BASE_URL}/eam/template/query`
}