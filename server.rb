require 'sinatra'
require 'haml'

# POST /
# 尝试保存图片，并返回图片地址
post '/' do

  filename = params['fname'] || params['filename']
  img_url  = url("/img/#{filename}")

  # Flash提交过来的文件内容已经变成了
  # 一个字符串，可以以表单字段的方式
  # 获取到:
  filebody = params['FileData']

  puts "file received: #{filename}"
  puts "size: #{filebody.size}"

  # 将文件内容（已经是字符串）写入磁盘
  File.open( image_path(filename), 'w') { |f| f.write filebody }

  %Q({
    "dataList"    : [456347479],
    "result"      : "success",
    "miniImgUrls" : ["#{img_url}"],
    "imgUrls"     : ["#{img_url}"]
  })
end


# POST /fail
# 永远会上传失败的接口
# 随机产生一个错误代码返回
post '/fail' do
  %Q({
    "result"  : "fail",
    "msg"     : "#{%w(imgTooBig imgTypeErr maxImageSpaceExceed maxImgPerAlbumExceeded).sample}"
  })
end

# POST /fail/自定义错误信息
# 永远会上传失败的接口
# 使用自定义错误信息
post '/fail/:msg' do |msg|
  %Q({
    "result"  : "fail",
    "msg"     : "#{msg}"
  })
end

# POST /random
# 随机返回成功或失败
post '/random' do 
  if rand > 0.5
    call env.merge("PATH_INFO" => '/fail')
  else
    call env.merge("PATH_INFO" => '/' )
  end
end

get '/img/:file' do |file|
 send_file image_path(file)
end

get('/') { haml :demo }

def image_path(file)
 "tmp/image-#{file}"
end
