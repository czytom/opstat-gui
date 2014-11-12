class PluginsController < ApplicationController
  # GET /plugins
  # GET /plugins.json
  def index
     
    @client = Client.find_by_login('powermedia')
    p @client

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @client }
    end
  end

  # GET /plugins/1
  # GET /plugins/1.json
  def show
    @client = Client.find_by_login('powermedia')
    @plugin = @client.get_plugin(params[:id])

    case params[:period]
    when "last_hour"
      start = Time.now - 3600
    when "6h"
      start = Time.now - (3600 * 6)
    when "1d"
      start = Time.now - (3600 * 24)
    when "7d"
      start = Time.now - (3600 * 24 * 7)
    when "30d"
      start = Time.now - (3600 * 24 * 7 * 30)
    else
      start = Time.now - 3600
    end
    @charts = @plugin.chart_data(start: start, host_id: @plugin.host.id, plugin_id: @plugin.id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @plugin }
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
end