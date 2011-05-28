{*
TestLink Open Source Project - http://testlink.sourceforge.net/ 
@filesource	tcStepEdit.tpl

Purpose: create/edit test case step

@internal revisions
20110217 - Julian - BUGID 3737, 4002, 4250 - Cancel Button was not working properly
20110209 - Julian - BUGID 4230 - removed old code to set focus on step
20110114 - asimon - simplified checking for editor type by usage of $gui->editorType
20110112 - Julian - BUGID 3901 - Scroll window to step implemented for vertical layout and
                                 newly added steps
20110111 - Julian - Improved modified warning message when navigating away without saving
20110106 - franciscom - BUGID 4136 - missing implementation on BUGID 3241
                                     layout was not used on CREATE
*}

{$cfg_section=$smarty.template|basename|replace:".tpl":""}
{config_load file="input_dimensions.conf" section=$cfg_section}


{$module='lib/testcases/'}
{$tcase_id=$gui->tcase_id}
{$tcversion_id=$gui->tcversion_id}

{* Used on several operations to implement goback *}
{$goBackActionURLencoded=$gui->goBackAction|escape:'url'}
{$url_args="tcEdit.php?doAction=editStep&tproject_id={$gui->tproject_id}&testcase_id=$tcase_id&tcversion_id=$tcversion_id"}
{$url_args="$url_args&goback_url=$goBackActionURLencoded&step_id="}
{$hrefEditStep="$basehref$module$url_args"}

{lang_get var="labels"
          s="warning_step_number_already_exists,warning,warning_step_number,
             expected_results,step_actions,step_number_verbose,btn_cancel,btn_create_step,
             btn_copy_step,btn_save,cancel,warning_unsaved,step_number,execution_type_short_descr,
             title_created,version,by,summary,preconditions,title_last_mod"}

{include file="inc_head.tpl" openHead='yes' jsValidate="yes" editorType=$gui->editorType}
{include file="inc_ext_js.tpl"}

<script type="text/javascript" src="gui/javascript/ext_extensions.js" language="javascript"></script>

<script type="text/javascript">
var warning_step_number = "{$labels.warning_step_number|escape:'javascript'}";
var alert_box_title = "{$labels.warning|escape:'javascript'}";
var warning_step_number_already_exists = "{$labels.warning_step_number_already_exists|escape:'javascript'}";

function validateForm(the_form,step_set,step_number_on_edit)
{
	var value = '';
	var status_ok = true;
	var feedback = '';
	var value_found_on_set=false;
	var value_step_mistmatch=false;
	value = parseInt(the_form.step_number.value);

	if( isNaN(value) || value <= 0)
	{
		alert_message(alert_box_title,warning_step_number);
		selectField(the_form,'step_number');
		return false;
	}

  // check is step number is free/available
  // alert('#1# - step_set:' + step_set + ' - step_set.length:' + step_set.length);
  // alert('#2# - step_numver.value:' + value + ' - step_number_on_edit:' + step_number_on_edit);
  if( step_set.length > 0 )
  {
    value_found_on_set = (step_set.indexOf(value) >= 0);
    value_step_mistmatch = (value != step_number_on_edit);
    // alert('#3# - value_found_on_set:' + value_found_on_set + ' - value_step_mistmatch:' + value_step_mistmatch);

    if(value_found_on_set && value_step_mistmatch)
    {
      feedback = warning_step_number_already_exists.replace('%s',value);
 	    alert_message(alert_box_title,feedback);
		  selectField(the_form,'step_number');
		  return false;
		}
  }
	return Ext.ux.requireSessionAndSubmit(the_form);
}
</script>

{if $tlCfg->gui->checkNotSaved}
<script type="text/javascript">
var unload_msg = "{$labels.warning_unsaved|escape:'javascript'}";
var tc_editor = "{$gui->editorType}";
</script>
<script src="gui/javascript/checkmodified.js" type="text/javascript"></script>
{/if}
</head>

{* BUGID 3901: Edit Test Case STEP - scroll window to show selected step *}
{if $gui->action == 'createStep' || $gui->action == 'doCreateStep'}
	{$scrollPosition='new_step'}
{else}
	{$stepToScrollTo=$gui->step_number}
	{$scrollPosition="step_row_$stepToScrollTo"}
{/if}

<body onLoad="scrollToShowMe('{$scrollPosition}')">
<h1 class="title">{$gui->main_descr}</h1> 

<div class="workBack" style="width:98.6%;">

{if $gui->user_feedback != ''}
	<div>
		<p class="info">{$gui->user_feedback}</p>
	</div>
{/if}

{if $gui->has_been_executed}
    {lang_get s='warning_editing_executed_step' var="warning_edit_msg"}
    <div class="messages" align="center">{$warning_edit_msg}</div>
{/if}

{*
DEBUG: $gui->operation: {$gui->operation} <br>
DEBUG: $gui->action: {$gui->action} <br>
*}

<form method="post" action="lib/testcases/tcEdit.php" name="tcStepEdit"
      onSubmit="return validateForm(this,'{$gui->step_set}',{$gui->step_number});">

	<input type="hidden" name="tproject_id" value="{$gui->tproject_id}" />
	<input type="hidden" name="testcase_id" value="{$gui->tcase_id}" />
	<input type="hidden" name="tcversion_id" value="{$gui->tcversion_id}" />
	<input type="hidden" name="doAction" value="" />
 	<input type="hidden" name="show_mode" value="{$gui->show_mode}" />
	<input type="hidden" name="step_id" value="{$gui->step_id}" />
	<input type="hidden" name="step_number" value="{$gui->step_number}" />
	<input type="hidden" name="goback_url" value="{$gui->goBackAction}" />


		{include file="testcases/inc_tcbody.tpl" 
             inc_tcbody_close_table=true
             inc_tcbody_testcase=$gui->testcase
		         inc_tcbody_show_title="yes"
             inc_tcbody_tableColspan=2
             inc_tcbody_labels=$labels
             inc_tcbody_author_userinfo=$gui->authorObj
             inc_tcbody_updater_userinfo=$gui->updaterObj
             inc_tcbody_cf=null}



	{* when save or cancel is pressed do not show modification warning *}
	<div class="groupBtn">
		<input id="do_update_step" type="submit" name="do_update_step" 
		       onclick="show_modified_warning=false; doAction.value='{$gui->operation}'" value="{$labels.btn_save}" />

    {if $gui->operation == 'doUpdateStep'}
		  <input id="do_create_step" type="submit" name="do_create_step" 
		         onclick="doAction.value='createStep'" value="{$labels.btn_create_step}" />

		  <input id="do_copy_step" type="submit" name="do_copy_step" 
		         onclick="doAction.value='doCopyStep'" value="{$labels.btn_copy_step}" />
    {/if}

  	<input type="button" name="cancel" value="{$labels.btn_cancel}"
    	   onclick="show_modified_warning=false; location='{$gui->goback_url}';" />
	</div>	

  <table class="simple">
	{if $gui->steps_results_layout == "horizontal"}
  	<tr>
  		<th width="{$gui->tableColspan}">{$labels.step_number}</th>
  		{* Julian: added width to show columns step details and expected
  		 * results at approximately same size (step details get 45%
  		 * expected results get the rest)
  		 *}
		<th width="45%">{$labels.step_actions}</th>
  		<th>{$labels.expected_results}</th>
      {if $gui->automationEnabled}
  		  <th width="25">{$labels.execution_type_short_descr}</th>
  		{/if}  
  	</tr>
  
  {if $gui->tcaseSteps != ''}
   	{foreach from=$gui->tcaseSteps item=step_info}
  	  <tr id="step_row_{$step_info.step_number}">
      {if $step_info.step_number == $gui->step_number}
		    <td style="text-align:left;">{$gui->step_number}</td>
  		  <td>{$steps}</td>
  		  <td>{$expected_results}</td>
		    {if $gui->automationEnabled}
		    <td>
		    	<select name="exec_type" onchange="content_modified = true">
        	  	{html_options options=$gui->execution_types selected=$gui->step_exec_type}
	        </select>
      	</td>
      	{/if}
      {else}
        <td style="text-align:left;"><a href="{$hrefEditStep}{$step_info.id}">{$step_info.step_number}</a></td>
  	  	<td ><a href="{$hrefEditStep}{$step_info.id}">{$step_info.actions}</a></td>
  	  	<td ><a href="{$hrefEditStep}{$step_info.id}">{$step_info.expected_results}</a></td>
        {if $gui->automationEnabled}
  	  	  <td><a href="{$hrefEditStep}{$step_info.id}">{$gui->execution_types[$step_info.execution_type]}</a></td>
  	  	{/if}  
      {/if}
  	  </tr>
    {/foreach}
  {/if}
  {else} {* Vertical layout *}
	{foreach from=$gui->tcaseSteps item=step_info}
	<tr id="step_row_{$step_info.step_number}">
		<th width="20">{$args_labels.step_number} {$step_info.step_number}</th>
		<th>{$labels.step_actions}</th>
		{if $gui->automationEnabled}
		{if $step_info.step_number == $gui->step_number}
		<th width="200">{$labels.execution_type_short_descr}:
			<select name="exec_type" onchange="content_modified = true">
				{html_options options=$gui->execution_types selected=$gui->step_exec_type}
	        </select>
		</th>
		{else}
			<th>{$labels.execution_type_short_descr}:
				{$gui->execution_types[$step_info.execution_type]}</th>
		{/if}
		{else}
		<th>&nbsp;</th>
		{/if} {* automation *}
		{if $edit_enabled}
		<th>&nbsp;</th>
		{/if}
	</tr>
	<tr>
		<td>&nbsp;</td>
		{if $step_info.step_number == $gui->step_number}
		<td colspan="2">{$steps}</td>
		{else}
		<td colspan="2"><a href="{$hrefEditStep}{$step_info.id}">{$step_info.actions}</a></td>
		{/if}
	</tr>
	<tr>
		<th style="background: transparent; border: none"></th>
		<th colspan="2">{$labels.expected_results}</th>
	</tr>
	<tr>
		<td>&nbsp;</td>
		{if $step_info.step_number == $gui->step_number}
		<td colspan="2">{$expected_results}</td>
		{else}
		<td colspan="2" style="padding: 0.5em 0.5em 2em 0.5em"><a href="{$hrefEditStep}{$step_info.id}">{$step_info.expected_results}</a></td>
		{/if}
	</tr>
	{/foreach}
  {/if}

  {if $gui->action == 'createStep' || $gui->action == 'doCreateStep'}
  	{* BUGID 4136 *}
  	{* We have forgotten to manage layout here *}
		{if $gui->steps_results_layout == "horizontal"}
	  	<tr id="new_step">
			  <td style="text-align:left;">{$gui->step_number}</td>
	  		<td>{$steps}</td>
	  		<td>{$expected_results}</td>
			    {if $gui->automationEnabled}
			    <td>
			    	<select name="exec_type" onchange="content_modified = true">
	        	  	{html_options options=$gui->execution_types selected=$gui->step_exec_type}
		        </select>
	      	</td>
	      	{/if}
	  	</tr>
  	{else}
			<tr id="new_step">
				<th width="20">{$args_labels.step_number} {$gui->step_number}</th>
				<th>{$labels.step_actions}</th>
				{if $gui->automationEnabled}
					<th width="200">{$labels.execution_type_short_descr}:
							<select name="exec_type" onchange="content_modified = true">
								{html_options options=$gui->execution_types selected=$gui->step_exec_type}
			  	    </select>
					</th>
    	  {/if}
				<tr>
					<td>&nbsp;</td>
    	  	<td colspan="2">{$steps}</td>
				</tr>
				<tr>
					<th style="background: transparent; border: none"></th>
					<th colspan="2">{$labels.expected_results}</th>
				</tr>
				<tr>
					<td>&nbsp;</td>
    	  	<td colspan="2" style="padding: 0.5em 0.5em 2em 0.5em"> {$expected_results}</td>
				</tr>
			<tr>
  	{/if}
  {/if}
  </table>	
  <p>
  {* when save or cancel is pressed do not show modification warning *}
	<div class="groupBtn" id="buttons_update_mode">
		<input id="do_update_step" type="submit" name="do_update_step" 
		       onclick="show_modified_warning=false; doAction.value='{$gui->operation}'" value="{$labels.btn_save}" />

    {if $gui->operation == 'doUpdateStep'}
		  <input id="do_create_step" type="submit" name="do_create_step" 
		         onclick="doAction.value='createStep'" value="{$labels.btn_create_step}" />

		  <input id="do_copy_step" type="submit" name="do_copy_step" 
		         onclick="doAction.value='doCopyStep'" value="{$labels.btn_copy_step}" />
    {/if}

  	<input type="button" id="cancel_in_update_mode" name="cancel" value="{$labels.btn_cancel}"
    	   onclick="show_modified_warning=false; location='{$gui->goback_url}';" />
	</div>	
</form>

</div>
</body>
</html>
