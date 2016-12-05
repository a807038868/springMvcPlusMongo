<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="../inc.jsp"></jsp:include>
<meta http-equiv="X-UA-Compatible" content="edge" />
<c:if test="${fn:contains(sessionInfo.resourceList, '/pestMoniNode/edit')}">
	<script type="text/javascript">
		$.canEdit = true;
	</script>
</c:if>
<c:if test="${fn:contains(sessionInfo.resourceList, '/pestMoniNode/delete')}">
	<script type="text/javascript">
		$.canDelete = true;
	</script>
</c:if>
<title>监测站管理</title>
	<script type="text/javascript">
	
	var dataGrid;
	/* 默认显示所有的资源 */
	$(function() {
		dataGrid = $('#dataGrid').datagrid({
			url : '${ctx}' + '/pestMoniNode/dataGrid',
			striped : true,
			rownumbers : false,//是否显示行号
			pagination : true,
			singleSelect : false,//允许选择多行
			idField : 'id',
			sortName : 'id',
			sortOrder : 'asc',
			pageSize : 50,
			pageList : [ 10, 20, 30, 40, 50, 100, 200, 300, 400, 500 ],
			frozenColumns : [ [ {
				width : '30',
				field : 'ck',
				checkbox : true
			},{
				width : '150',
				title : '监测点名称',
				field : 'name',
				sortable : true
			} ,{
				width : '200',
				title : '创建日期',
				field : 'createDate',
				sortable : true
			},{
				width : '100',
				title : '坐标：x',
				field : 'locationX',
				sortable : true
			},{
				width : '100',
				title : '坐标：y',
				field : 'locationY',
				sortable : true
			},{
				width : '200',
				title : '监测位置',
				field : 'address',
				sortable : true
			},{
				width : '250',
				title : '描述',
				field : 'description',
				sortable : true
			}, {
				field : 'active',
				title : '操作',
				width : 120,
				formatter : function(value, row, index) {
					var str = '&nbsp;';
					if ($.canEdit) {
							str += $.formatString('<a href="javascript:void(0)" onclick="editFun(\'{0}\');" >编辑</a>', row.id);
						}
					str += '&nbsp;&nbsp;|&nbsp;&nbsp;';
					if ($.canDelete) {
						str += $.formatString('<a href="javascript:void(0)" onclick="deleteFun({0});" >删除</a>', row.id);
					}
					return str;
				}
			} ] ],
			toolbar : '#toolbar'
		});
	});
	
	function deleteFun(id) {
		/* 定义json数组ids */
		var ids = [];
		if (id == undefined) {//点击删除按钮才会触发这个 
			var rows = dataGrid.datagrid('getSelections');
			if (rows.length==0) {  
				parent.$.messager.alert("提示", "请选择要删除的行！", "info");  
	            return;  
	        }else{ 
				for(i=0;i<rows.length;i++)
					ids.push(rows[i].id);
	        }
		} else {//点击操作里面的删除图标会触发这个
			dataGrid.datagrid('unselectAll').datagrid('uncheckAll');
			ids.push(id);
		}
		var jsonIds = JSON.stringify(ids);
		parent.$.messager.confirm('询问', '您是否要删除当前选中的资源？', function(b) {
			if (b) {
					progressLoad();
					$.post('${ctx}/pestMoniNode/delete', {
						ids : jsonIds
					}, function(result) {
						if (result.success) {
							//清除datagrid之前的选择，防止下次删除时重复删除
							dataGrid.datagrid('clearSelections');
							parent.$.messager.alert('提示', result.msg, 'info');
							dataGrid.datagrid('reload');
						}
						progressClose();
					}, 'JSON');
			}
		});
	}
	
	function detailFun(id) {
		if (id == undefined) {
			var rows = dataGrid.datagrid('getSelections');
			id = rows[0].id;
		} else {
			dataGrid.datagrid('unselectAll').datagrid('uncheckAll');
		}
		parent.$.modalDialog({
			title : '详情',
			width : 500,
			height : 300,
			href : '${ctx}/pestMoniNode/detailPage?id=' + id
		});
	}
	
	function editFun(id) {
		if (id == undefined) {
			var rows = dataGrid.datagrid('getSelections');
			id = rows[0].id;
		} else {
			dataGrid.datagrid('unselectAll').datagrid('uncheckAll');
		}
		parent.$.modalDialog({
			title : '编辑',
			width : 600,
			height : 500,
			href : '${ctx}/pestMoniNode/editPage?id=' + id,
			buttons : [ {
				text : '编辑',
				handler : function() {
					parent.$.modalDialog.openner_dataGrid = dataGrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
					var f = parent.$.modalDialog.handler.find('#dataEditForm');
					f.submit();
				}
			} ]
		});
	}
	
		function addFun() {
		parent.$.modalDialog({
			title : '添加',
			width : 800,
			height : 600,
			href : '${ctx}/pestMoniNode/addPage',
			buttons : [ {
				text : '添加',
				handler : function() {
					parent.$.modalDialog.openner_dataGrid = dataGrid;//因为添加成功之后，需要刷新这个treeGrid，所以先预定义好
					var f = parent.$.modalDialog.handler.find('#moniNodeAddForm');
					f.submit();
				}
			} ]
		});
	}
	
	
	function searchFun() {
		parent.$.modalDialog({
			title : '检索',
			width : 600,
			height : 500,
			href : '${ctx}/pestMoniNode/getSearchPage',
			buttons : [ {
				text : '检索',
				handler : function() {
					parent.$.modalDialog.openner_dataGrid = dataGrid;//因为添加成功之后，需要刷新这个treeGrid，所以先预定义好
					var f = parent.$.modalDialog.handler.find('#dataAddForm');
					f.submit();
				}
			} ]
		});
	}
	</script>
</head>
<body class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',fit:true,border:false">
		<table id="dataGrid" data-options="fit:true,border:false"></table>
	</div>
	<div id="toolbar" style="display: none;">
		<c:if test="${fn:contains(sessionInfo.resourceList, '/pestMoniNode/add')}">
			<a onclick="addFun();" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon_add'">添加</a>
		</c:if>
	
		<c:if test="${fn:contains(sessionInfo.resourceList, '/pestMoniNode/delete')}">
			<a onclick="deleteFun();" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon_del'">删除</a>
		</c:if>
		<c:if test="${fn:contains(sessionInfo.resourceList, '/pestMoniNode/search')}">
			<a onclick="searchFun();" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon_add'">检索</a>
		</c:if>
		<c:if test="${fn:contains(sessionInfo.resourceList, '/pestMoniNode/getExcel')}">
			<a onclick=";" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon_add'">Excel</a>
		</c:if>
	</div>
</body>
</html>