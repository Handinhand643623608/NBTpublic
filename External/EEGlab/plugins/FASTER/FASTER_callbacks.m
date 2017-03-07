function varargout=FASTER_callbacks(src,eventdata,varargin)

% Copyright (C) 2010 Hugh Nolan, Robert Whelan and Richard Reilly, Trinity College Dublin,
% Ireland
% nolanhu@tcd.ie, robert.whelan@tcd.ie
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

top_nargout=nargout;

if nargin < 2
    %This should never happen.
    return;
elseif nargin==2
    x=get(src,'Parent');
    if (x==0)
        uiresume(src);
    else
        uiresume(x);
    end
elseif nargin>=3
    %try
    % Evaluate the first argument in varargin as the function name and the rest
    % as the arguments to that function
    eval(sprintf('%s(src,eventdata,varargin{2:end});',varargin{1}));
    %catch ME
    %    fprintf('Error: %s\n',ME.message);
    %end
end

    function do_nothing(src,eventdata)
        return;
    end

    function double_click_func(varargin)
        fprintf('Eval''d.\n');
        if (get(varargin{1},'Selected'))
            eval_string=[varargin{3} '('];
            for i=4:nargin
                eval_string=[eval_string varargin{i} ','];
            end
            if eval_string(end)==','
                eval_string = [eval_string(1:end-1) ');'];
            end
            eval(eval_string);
        end
    end

    function fileselect(src,eventdata,tbhandle,name,handle)
        [file_to_do pathname] = uigetfile('*.*',name);
        if (file_to_do~=0)
            set(tbhandle,'String',[pathname file_to_do]);
        else
            return;
        end

        option_wrapper=get(handle,'UserData');
        eval(sprintf('option_wrapper.options.%s = ''%s'';',get(tbhandle,'UserData'),[pathname file_to_do]));
        set(handle,'UserData',option_wrapper);
        update_controls(src,eventdata,handle);
    end

    function folderselect(src,eventdata,tbhandle,name,handle)
        folder_to_do = uigetdir(cd,name);
        if (folder_to_do~=0)
            set(tbhandle,'String',folder_to_do);
        else
            return;
        end

        option_wrapper=get(handle,'UserData');
        eval(sprintf('option_wrapper.options.%s = ''%s'';',get(tbhandle,'UserData'),folder_to_do));
        set(handle,'UserData',option_wrapper);
        update_controls(src,eventdata,handle);
    end

    function changelist(src,eventdata,listbox,list_strings,value)
        set(listbox,'String',list_strings,'Value',1);
        option_wrapper=get(listbox,'UserData');
        option_wrapper.last_value=1;
        option_wrapper.current_group=value;
        set(listbox,'UserData',option_wrapper);
    end

    function set_window_value(src,eventdata,handle)
        option_wrapper=get(handle,'UserData');
        current_item=get(src,'UserData');
        if (strcmpi(get(src,'Style'),'edit'))
            string=get(src,'String');
            if isempty(string)
                string='[]';
            end
            if (string(1)~='[')
                string = [ '[' string ];
            end
            if (string(end)~=']')
                string = [ string ']'];
            end

            try
                %r=eval(string);
                eval(sprintf('option_wrapper.options.%s=%s;',current_item,string));
                %if iscell(r)

                %end
                %set(src,'Value',eval(string)); % Is this at all necessary except as a temporary variable? I don't think so.
            catch
                close(get(src,'Parent'));
                ew=errordlg('Invalid assignment.','Assignment error','modal');
                set(0,'Units','pixels');
                screensize = get(0,'ScreenSize');
                screensize = screensize(1,[3 4]);
                p=get(ew,'Position');
                set(ew,'Position',[(screensize(1)-p(3))/2 (screensize(2)-p(4))/2 p(3) p(4)]);
                return;
            end


        else
            eval(sprintf('option_wrapper.options.%s=get(src,''Value'');',current_item));
        end

        set(handle,'UserData',option_wrapper);
    end

    function set_save_options(src,eventdata,number,handle)
        option_wrapper=get(handle,'UserData');
        option_wrapper.options.save_options(number)=get(src,'Value');
        set(handle,'UserData',option_wrapper);
    end

    function pop_up(src,eventdata,funchand)
        option_wrapper=get(src,'UserData');
        x=get(src,'Value');
        if (x==option_wrapper.last_value)
            funchand(option_wrapper.window_handles{option_wrapper.current_group}{x},src);
        end
        option_wrapper.last_value=x;
        set(src,'UserData',option_wrapper);
    end

    function option_window_close(src,eventdata,handle,control_handles,figure_handle)
        if nargin==4
            figure_handle=src;
        end
        option_wrapper=get(handle,'UserData');
        try
            for p=2:2:length(control_handles)
                current_item=get(control_handles(p),'UserData');

                if (strcmpi(get(control_handles(p),'Style'),'edit'))
                    string=get(control_handles(p),'String');
                    if isempty(string)
                        string='[]';
                    end
                    if (string(1)~='[')
                        string = [ '[' string ];
                    end
                    if (string(end)~=']')
                        string = [ string ']'];
                    end

                    try
                        eval(sprintf('option_wrapper.options.%s=%s;',current_item,string));
                        %set(control_handles(p),'Value',eval(string));
                    catch
                        ew=errordlg('Invalid assignment.','Assignment error','modal');
                        set(0,'Units','pixels');
                        screensize = get(0,'ScreenSize');
                        screensize = screensize(1,[3 4]);
                        pos=get(ew,'Position');
                        set(ew,'Units','Pixels','Position',[(screensize(1)-pos(3))/2 (screensize(2)-pos(4))/2 pos(3) pos(4)]);
                        return;
                    end
                else
                    eval(sprintf('option_wrapper.options.%s=get(control_handles(p),''Value'');',current_item));
                end
                %eval(sprintf('option_wrapper.options.%s=get(control_handles(p),''Value'');',current_item));
            end
        catch
            ew2=errordlg('Something went wrong.','Error','modal');
            set(0,'Units','pixels');
            screensize = get(0,'ScreenSize');
            screensize = screensize(1,[3 4]);
            p=get(ew2,'Position');
            set(ew2,'Units','Pixels','Position',[(screensize(1)-p(3))/2 (screensize(2)-p(4))/2 p(3) p(4)]);
            delete(figure_handle);
        end
        set(handle,'UserData',option_wrapper);
        set(figure_handle,'WindowStyle','normal');
        delete(figure_handle);
    end

    function main_window_close(src,eventdata,handle)
        delete(src);
    end

    function error_window(src,eventdata,string)
        bgcolor=[0.9 0.9 0.9];
        ew=figure;
        set(0,'Units','pixels');
        screensize = get(0,'ScreenSize');
        screensize = screensize(1,[3 4]);
        set(ew,'Units','Pixels','Position',[(screensize(1)/2-100) (screensize(2)/2-50) 200 100],'WindowStyle','modal','Color',bgcolor);
        uicontrol('FontSize',12,'Style','text','String',string,'Units','Normalized','Position',[0 0.5 1 0.5],'BackgroundColor',bgcolor);
        uicontrol('FontSize',12,'Style','pushbutton','String','OK','Units','Normalized','Position',[0.35 0.1 0.3 0.3],'Callback',{@close_this,ew},'BackgroundColor',bgcolor);

        function close_this(src,eventdata,handle)
            set(handle,'WindowStyle','normal');
            delete(handle);
        end
    end

    function set_onoff_options(src,eventdata,number,handle)
        option_wrapper=get(handle,'UserData');
        option_wrapper.options{2}{number}{end}={get(src,'Value')};
        set(handle,'UserData',options);
    end

    function run_FASTER(src,eventdata,handle)
        option_wrapper=get(handle,'UserData');
        using_ALLEEG=option_wrapper.options.file_options.using_ALLEEG;
        if ~using_ALLEEG && (isempty(option_wrapper.options.file_options.folder_name) || ~exist(option_wrapper.options.file_options.folder_name,'dir'))
            errordlg('Invalid job folder selected.','Error','modal');
            %assignin('base','optins',option_wrapper);
            return;
        end
        if (~isempty(option_wrapper.options.file_options.output_folder_name) && ~exist(option_wrapper.options.file_options.output_folder_name,'dir'))
            errordlg('Invalid output folder selected.','Error','modal');
            return;
        end
        if (isempty(option_wrapper.options.file_options.channel_locations))
            if (option_wrapper.options.file_options.is_bdf==1)
                errordlg('Must enter channel locations for .bdf files.','Error','modal');
                return;
            else
                button = questdlg(sprintf('No channel locations entered.\nDo all .set files have channel locations?'),'Channel locations','Yes','No','Yes');
                if strcmp(button,'No')
                    return;
                end
            end
        end
        if (option_wrapper.options.ica_options.run_ica && ~isempty(setdiff(option_wrapper.options.ica_options.ica_channels,[option_wrapper.options.channel_options.eeg_chans option_wrapper.options.channel_options.ext_chans])))
            errordlg('Selected ICA channels are not a subset of selected EEG and external channels.');
            return;
        end

        % v=version();
        % dots=strfind(v,'.');
        % v_num=str2num(v(1:dots(2)-1));
        %
        % if v_num>7.4
        %     FASTER(option_wrapper);
        % else
        %     FASTER_compat(option_wrapper);
        % end

        % Version number check is awkward at the moment.
        % Using lasterror for the moment until it is removed
        % completely.

        % If none of the above checks returned, run FASTER!
        try
            FASTER(option_wrapper);
        catch
            m=lasterror;
            if exist('my_queue_file','var') && ~isempty(my_queue_file) && exist(my_queue_file,'file')
                delete(my_queue_file);
            end
            if exist('my_proc_file','var') && ~isempty(my_proc_file) && exist(my_proc_file,'file')
                delete(my_proc_file);
            end
            assignin('base','m',m);
            rethrow(m);
        end
    end

    function stop(src,eventdata)
        error('Stopped FASTER!\n');
    end

    function new_job(src,eventdata,handle)
        folder_to_do = uigetdir(cd,'Open folder to process');
        [root_folder f1 f2] = fileparts(folder_to_do);

        [pathname file_to_save] = uiputfile('*.eegjob','Save job',[folder_to_do filesep f1 f2 '.eegjob']);
        if (all(folder_to_do~=0) && all(file_to_save~=0))
            option_wrapper.file_options.folder_name=folder_to_do;

            save_job([],[],handle,[pathname filesep file_to_save]);
        end
    end

    function open_job(src,eventdata,handle,std_options)
        [file_to_do pathname] = uigetfile('*.eegjob','Select EEG job to open');
        option_wrapper=get(handle,'UserData');
        if (file_to_do~=0)
            all=load([pathname filesep file_to_do],'-mat');
            or2=all.option_wrapper;
            
            using_ALLEEG=option_wrapper.options.file_options.using_ALLEEG;
            %if exist([pathname filesep 'ProcQ.eegQ'],'file')
            if ~using_ALLEEG
                if isfield(or2.options.file_options,'folder_name_rel') && ~isempty(or2.options.file_options.folder_name_rel)
                    try
                        startDir = make_relative_path(or2.options.file_options.folder_name_rel,pathname);
                        or2.options.file_options.folder_name=startDir;
                    catch
                        startDir=or2.options.file_options.folder_name;
                    end
                else
                    startDir=or2.options.file_options.folder_name;
                end
            else
                startDir=cd;
            end

            if (~using_ALLEEG && exist([startDir filesep file_to_do '_ProcQ.eegQ'],'file')) || (using_ALLEEG && exist([startDir filesep 'ProcQ.eegQ'],'file'))
                button = questdlg(sprintf('Queue file present.\nJoining the queue will add this computer to an already running FASTER session (cannot be used if FASTER was started from EEGLAB).\n\nOverwriting will delete the queue file and start from the beginning. Use this if an error occurred previously, or if processing was aborted before finishing the job (resume will function as normal).\n\nCancelling will abort loading this file.'),'Queue file detected','Join','Reset Queue','Cancel','Join');
                if strcmp(button,'Cancel')
                    return;
                elseif strcmp(button,'Reset Queue')
                    button = questdlg(sprintf('Warning: resetting will remove the queue file and other tracking files. Please ensure no other computers are using this job file for processing.\nContinue?'),'Restart warning','Yes','No','No');
                    if strcmp(button,'No')
                        return;
                    end
                    if ~using_ALLEEG
                        delete([startDir filesep file_to_do '_ProcQ.eegQ']);
                    else
                        delete([startDir filesep 'ProcQ.eegQ']);
                    end
                    if exist([startDir filesep 'Queue'],'dir')
                        D=dir([startDir filesep 'Queue']);
                        for v=1:length(D)
                            if ~strcmp(D(v).name,'.') && ~strcmp(D(v).name,'..')
                                delete([startDir filesep 'Queue' filesep D(v).name]);
                            end
                        end
                        rmdir([startDir filesep 'Queue']);
                    end
                    if exist([startDir filesep 'Processing'],'dir')
                        D=dir([startDir filesep 'Processing']);
                        for v=1:length(D)
                            if ~strcmp(D(v).name,'.') && ~strcmp(D(v).name,'..')
                                delete([startDir filesep 'Processing' filesep D(v).name]);
                            end
                        end
                        rmdir([startDir filesep 'Processing']);
                    end
                end
            end

            or2.options.file_options.using_ALLEEG=option_wrapper.options.file_options.using_ALLEEG;
            option_wrapper.options=check_options(src,eventdata,std_options,or2.options);
            option_wrapper.options.file_options.resume=1;
            option_wrapper.options.job_filename=[pathname filesep file_to_do];
        end
        set(handle,'UserData',option_wrapper);
        update_controls(src,eventdata,handle);
    end

    function varargout=check_options(src,eventdata,op1,op2)
        names=fieldnames(op1);
        for v=1:length(names)
            if ~isfield(op2,names{v})
                op2.(names{v})=op1.(names{v});
            elseif isstruct(op1.(names{v}))
                names_2 = fieldnames(op1.(names{v}));
                for t=1:length(names_2)
                    if ~isfield(op2.(names{v}),names_2{t})
                        op2.(names{v}).(names_2{t})=op1.(names{v}).(names_2{t});
                    elseif isstruct(op1.(names{v}).(names_2{t})) % Max three levels of structs
                        names_3 = fieldnames(op1.(names{v}).(names_2{t}));
                        for r=1:length(names_3)
                            if ~isfield(op2.(names{v}).(names_2{t}),names_3{r}) || ~all(size(op2.(names{v}).(names_2{t}).(names_3{r}))==size(op1.(names{v}).(names_2{t}).(names_3{r})))
                                op2.(names{v}).(names_2{t}).(names_3{r})=op1.(names{v}).(names_2{t}).(names_3{r});
                            end
                        end
                    end
                end
            end
        end
        if nargout==1
            varargout{1}=op2;
        end
    end

    function update_value(src,eventdata,handle)
        option_wrapper=get(handle,'UserData');
        if (strcmp(get(src,'Style'),'edit'))
            eval(sprintf('option_wrapper.options.%s = ''%s'';',get(src,'UserData'),get(src,'String')));
        else
            eval(sprintf('option_wrapper.options.%s = %f;',get(src,'UserData'),get(src,'Value')));
        end
        set(handle,'UserData',option_wrapper);
        update_controls(src,eventdata,handle);
    end

    function save_job(src,eventdata,handle,full_filename)
        option_wrapper=get(handle,'UserData');
        tmp_using=option_wrapper.options.file_options.using_ALLEEG;
        option_wrapper.options.file_options.using_ALLEEG=0;
        if nargin==3
            if isempty(option_wrapper.options.job_filename) || ~exist(option_wrapper.options.job_filename,'file')
                if isempty(option_wrapper.options.file_options.folder_name)
                    [pathname file_to_save] = uiputfile('*.eegjob','Save job');
                else
                    [root_folder f1 f2] = fileparts(option_wrapper.options.file_options.folder_name);
                    [pathname file_to_save] = uiputfile('*.eegjob','Save job',[option_wrapper.options.file_options.folder_name filesep option_wrapper.options.file_options.file_prefix f1 f2 '.eegjob']);
                end
                if (file_to_save==0)
                    return;
                end
                full_filename=[file_to_save filesep pathname];
            else
                full_filename=option_wrapper.options.job_filename;
            end
        end
        if ~isempty(option_wrapper.options.file_options.folder_name)
        if exist('file_to_save','var')
            option_wrapper.options.file_options.folder_name_rel=find_relative_path(option_wrapper.options.file_options.folder_name,file_to_save);
        else
            option_wrapper.options.file_options.folder_name_rel=find_relative_path(option_wrapper.options.file_options.folder_name,fileparts(option_wrapper.options.job_filename));
        end
        else
            option_wrapper.options.file_options.folder_name_rel=cell(0);
        end
        save(full_filename,'option_wrapper','-mat');
        option_wrapper.options.job_filename=full_filename;
        option_wrapper.options.file_options.using_ALLEEG=tmp_using;
        set(handle,'UserData',option_wrapper);
    end

    function save_new_job(src,eventdata,handle)
        option_wrapper=get(handle,'UserData');
        tmp_using=option_wrapper.options.file_options.using_ALLEEG;
        option_wrapper.options.file_options.using_ALLEEG=0;
        if isempty(option_wrapper.options.file_options.folder_name)
            [pathname file_to_save] = uiputfile('*.eegjob','Save job');
        else
            [root_folder f1 f2] = fileparts(option_wrapper.options.file_options.folder_name);
            [pathname file_to_save] = uiputfile('*.eegjob','Save job',[option_wrapper.options.file_options.folder_name filesep option_wrapper.options.file_options.file_prefix f1 f2 '.eegjob']);
        end
        if (file_to_save==0)
            return;
        end
        full_filename=[file_to_save filesep pathname];
        if exist('file_to_save','var')
            option_wrapper.options.file_options.folder_name_rel=find_relative_path(option_wrapper.options.file_options.folder_name,file_to_save);
        else
            option_wrapper.options.file_options.folder_name_rel=find_relative_path(option_wrapper.options.file_options.folder_name,root_folder);
        end
        save(full_filename,'option_wrapper','-mat');
        option_wrapper.options.job_filename=full_filename;
        option_wrapper.options.file_options.using_ALLEEG=tmp_using;
        set(handle,'UserData',option_wrapper);
    end

    function get_defaults(src,eventdata,handle,using_ALLEEG)
        option_wrapper=get(handle,'UserData');
        filename=which('FASTER_defaults.mat');
        if ~isempty(filename)
            x=load(filename,'-mat');
            option_wrapper_def=x.option_wrapper;
            option_wrapper_def.options.job_filename=[];
            option_wrapper_def.options.current_file=[];
            option_wrapper_def.options.current_file_num=1;
            %option_wrapper.options.file_options.using_ALLEEG=0;
        end

        option_wrapper_def.options.file_options.using_ALLEEG=using_ALLEEG;

        if (top_nargout>0)
            vout{1}=option_wrapper_def.options;
        else
            option_wrapper.options=option_wrapper_def.options;
            set(handle,'UserData',option_wrapper);
            update_controls(src,eventdata,handle);
        end
    end

    function update_controls(src,eventdata,handle)
        option_wrapper=get(handle,'UserData');
        for c=1:length(option_wrapper.save_handles)
            set(option_wrapper.save_handles(c),'Value',option_wrapper.options.save_options(c));
        end

        % File options etc
        for c=1:length(option_wrapper.other_handles)
            if (strcmp(get(option_wrapper.other_handles(c),'Style'),'edit') || strcmp(get(option_wrapper.other_handles(c),'Style'),'text'))
                set(option_wrapper.other_handles(c),'String',eval(['option_wrapper.options.' get(option_wrapper.other_handles(c),'UserData')]));
            elseif strcmp(get(option_wrapper.other_handles(c),'Style'),'pushbutton')

            else
                if (strcmp(get(option_wrapper.other_handles(c),'UserData'),'file_options.save_ALLEEG'))
                    if ~isempty(option_wrapper.options.file_options.output_folder_name)
                        option_wrapper.options.file_options.save_ALLEEG=1;
                        set(option_wrapper.other_handles(c),'Enable','off');
                    else
                        set(option_wrapper.other_handles(c),'Enable','on');
                    end
                end
                set(option_wrapper.other_handles(c),'Value',eval(['option_wrapper.options.' get(option_wrapper.other_handles(c),'UserData')]));
            end
        end
    end

    function save_defaults(src,eventdata,handle)
        option_wrapper=get(handle,'UserData');
        option_wrapper.job_filename=[];
        option_wrapper.options.using_ALLEEG=0;
        if ~isempty(which('FASTER_defaults.mat'))
            save(which('FASTER_defaults.mat'),'option_wrapper','-mat');
        else
            [root_folder] = fileparts(which('FASTER_callbacks.m'));
            save([root_folder filesep 'FASTER_defaults.mat'],'option_wrapper','-mat');
        end
    end

if top_nargout>0
    if (~exist('vout','var'))
        for u=1:top_nargout
            vout{u}=[];
        end
    end
    varargout=vout;
end

end

