import { globalActions } from '@/store/globalSlices'
import React from 'react'
import { useDispatch } from 'react-redux'

const Banner = () => {
  const dispatch = useDispatch()
  const { setCreateModal } = globalActions
 
  return (
    <main className="mx-auto text-center space-y-8">
      <h1 className="text-[45px] font-[600px] text-center leading-none">Vote Without Rigging</h1>
      <p className="text-[20px] font-[500px] text-center">
      {' '}
        This online voting system offers the highest level of transparency,
        control, security <br></br>and efficiency of election processes using
         <strong> Blockchain Technology</strong>{' '}
      </p>

      <button
        className="text-black h-[45px] w-[148px] rounded-full transition-all duration-300
        border border-gray-400 bg-white hover:bg-opacity-20 hover:text-white"
        onClick = {() => dispatch(setCreateModal('scale-100'))}
      >
        Create poll
      </button>
    </main>
  )
}

export default Banner
