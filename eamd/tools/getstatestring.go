package tools

import "eamd/models"

func GetStateString(state int) string {
	switch state {
	case models.GOODS_STATE_FREE, models.GOODS_STATE_RETURN:
		return "闲置"
	case models.GOODS_STATE_USE:
		return "使用中"
	case models.GOODS_STATE_LOSS:
		return "遗失"
	case models.GOODS_STATE_SCRAP:
		return "报废"
	}
	return ""
}
