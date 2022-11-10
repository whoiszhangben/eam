export function findAllParent(node, tree, parentNodes = [], index = 0) {
    if (!node || node.parent === null) {
        return
    }
    findParent(node, parentNodes, tree)
    let parentNode = parentNodes[index]
    findAllParent(parentNode, tree, parentNodes, ++index)
    return parentNodes
}

function findParent(node, parentNodes, tree) {
    for (let i = 0; i < tree.length; i++) {
        let item = tree[i]
        if (item.id === node.parent) {
            parentNodes.push(item)
            return
        }
        if (item.children && item.children.length > 0) {
            findParent(node, parentNodes, item.children)
        }
    }
}

export default findAllParent