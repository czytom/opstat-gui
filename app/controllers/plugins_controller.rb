class PluginsController < ApplicationController
  # GET /plugins
  # GET /plugins.json
  def index
     
    @plugins = Plugin.all.group_by{|u| u.type}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @plugins }
    end
  end

  # GET /plugins/1
  # GET /plugins/1.json
  def show
    @plugin = Plugin.find(params[:id])
    @host_plugins = Plugin.all(:host_id => @plugin.host_id)

    @charts = @plugin.chart_data(params)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @charts }
    end
  end

  # GET /plugins/new
  # GET /plugins/new.json
  def new
    @plugin = Plugin.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @plugin }
    end
  end

  # GET /plugins/1/edit
  def edit
    @plugin = Plugin.find(params[:id])
  end

  # POST /plugins
  # POST /plugins.json
  def create
    @plugin = Plugin.new(params[:plugin])

    respond_to do |format|
      if @plugin.save
        format.html { redirect_to @plugin, notice: 'Plugin was successfully created.' }
        format.json { render json: @plugin, status: :created, location: @plugin }
      else
        format.html { render action: "new" }
        format.json { render json: @plugin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /plugins/1
  # PUT /plugins/1.json
  def update
    @plugin = Plugin.find(params[:id])

    respond_to do |format|
      if @plugin.update_attributes(params[:plugin])
        format.html { redirect_to @plugin, notice: 'Plugin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @plugin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plugins/1
  # DELETE /plugins/1.json
  def destroy
    @plugin = Plugin.find(params[:id])
    @plugin.destroy

    respond_to do |format|
      format.html { redirect_to plugins_url }
      format.json { head :no_content }
    end
  end

  def plugin_of_type_old
    @charts = []
    @plugins = Plugin.where({:type => params[:plugin_type]}).all
    @plugins.each do |plugin|
      @charts << plugin.chart_data(params)[0]#they are returned as array so we need to get it from there
    end
  end
  def plugin_of_type
    @charts = Plugin.chart_data_of_type(params)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @plugin }
    end
  end
end
