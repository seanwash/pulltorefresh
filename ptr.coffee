###*
 * Pull to refresh!
 * @param  {jquery element} containerEl [description]
 * @param  {jquery element} ptrEl       [description]
 * @param  {jquery element} contentEl   [description]
###
class PullToRefresh
  constructor: (containerEl, ptrEl, contentEl) ->
    # Throw specific errors if everything we need to get going isn't available
    return console.error 'containerEl is not set for Pull To Refresh' unless containerEl?.length
    return console.error 'ptrEl is not set for Pull To Refresh' unless ptrEl?.length
    return console.error 'contentEl is not set for Pull To Refresh' unless contentEl?.length

    @containerEl = containerEl
    @ptrEl = ptrEl
    @contentEl =  contentEl

    @origContainerScrollTop = containerEl.scrollTop()
    @currentContainerScrollTop = containerEl.scrollTop()


    containerEl.on 'touchstart', (e) =>
      e = e.originalEvent
      @origContainerScrollTop = containerEl.scrollTop()
      @currentContainerScrollTop = if e.touches then e.touches[0].pageY else e.pageY


    containerEl.on 'touchmove', (e) =>
      e = e.originalEvent
      newContainerScrollTop = if e.touches then e.touches[0].pageY else e.pageY
      @delta = newContainerScrollTop - @currentContainerScrollTop

      @origContainerScrollTop = containerEl.scrollTop()

      if @delta >= 0 && @origContainerScrollTop <= 0
        e.preventDefault()
        @disableScrolling()

        if @delta >= 130
          @showReleaseMessage()
        else
          @showPullMessage()

        @setContentPan(@delta) unless $('body').is '.ptr-refreshing'
      else
        @enableScrolling()


    containerEl.on 'touchend', (e) =>
      if @origContainerScrollTop <= 0 && @delta >= 130 && !$('body').is('.ptr-refreshing')
        console.log 'PTR: REFRESH'
        @refresh()
      else
        @reset() if @origContainerScrollTop <= 0 && @delta >= 0 && !$('body').is('.ptr-refreshing')

      @delta = 0


  disableScrolling: =>
    @containerEl.addClass 'no-scroll'
    @contentEl.addClass 'no-scroll'


  enableScrolling: =>
    @containerEl.removeClass 'no-scroll'
    @contentEl.removeClass 'no-scroll'


  showPullMessage: =>
    @ptrEl.find('.message').text 'Pull to Refresh'


  showReleaseMessage: =>
    @ptrEl.find('.message').text 'Release to Refresh'


  showLoadingState: =>
    $('body').addClass 'ptr-animating ptr-refreshing'

    @ptrEl[0].style.transform = @ptrEl[0].style.webkitTransform = 'translate3d(0, 0, 0)'
    @contentEl[0].style.transform = @contentEl[0].style.webkitTransform = 'translate3d(0, 44px, 0)'

    setTimeout =>
      $('body').removeClass 'ptr-animating'
      @enableScrolling()
    , 240
